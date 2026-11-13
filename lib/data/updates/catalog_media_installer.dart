import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'catalog_file_verifier.dart';
import 'catalog_cry_formats.dart';
import 'catalog_manifest.dart';
import 'catalog_media_index.dart';

class CatalogMediaInstaller {
  CatalogMediaInstaller(this.verifier);
  final CatalogFileVerifier verifier;

  Future<void> install(
      {required File catalog,
      required File seed,
      required Directory previous,
      required Directory staging,
      required Directory target,
      required CatalogManifest manifest}) async {
    final activeDb =
        await openDatabase(catalog.path, readOnly: true, singleInstance: false);
    final seedDb =
        await openDatabase(seed.path, readOnly: true, singleInstance: false);
    late CatalogMediaIndex active;
    late CatalogMediaIndex bundled;
    try {
      final formats = await bundledCryFormats(seedDb);
      active = await CatalogMediaIndex.read(activeDb, cryFormats: formats);
      bundled = await CatalogMediaIndex.read(seedDb, cryFormats: formats);
    } finally {
      await activeDb.close();
      await seedDb.close();
    }
    final bundledIds = bundled.assets.values.map((media) => media.id).toSet();
    final package = <String, CatalogFile>{
      for (final file in manifest.files)
        if (file.path.startsWith('media/')) file.path: file,
    };
    for (final file in package.values) {
      if (!await verifier.matches(
          File('${staging.path}/${file.asset}'), file)) {
        throw const FormatException('Catalog media download is incomplete');
      }
    }
    final copied = <String>{};
    for (final media in active.assets.values) {
      if (bundledIds.contains(media.id) || !copied.add(media.path)) continue;
      final expected = CatalogFile(media.path,
          'media-${media.path.substring(6)}', media.bytes, media.id);
      final packaged = package[media.path];
      if (packaged != null &&
          (packaged.sha256 != media.id || packaged.bytes != media.bytes)) {
        throw const FormatException('Catalog media metadata mismatch');
      }
      final source = packaged == null
          ? File('${previous.path}/${media.path}')
          : File('${staging.path}/${packaged.asset}');
      if (!await verifier.matches(source, expected)) {
        throw const FormatException('Catalog requires unavailable media');
      }
      final destination = File('${target.path}/${media.path}');
      await destination.parent.create(recursive: true);
      await source.copy(destination.path);
    }
  }
}
