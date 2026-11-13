import 'dart:io';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pokeapp_flutter/data/updates/catalog_active_store.dart';
import 'package:pokeapp_flutter/data/updates/catalog_installer.dart';
import 'package:pokeapp_flutter/data/updates/catalog_manifest.dart';
import 'package:pokeapp_flutter/data/updates/catalog_media_resolver.dart';
import 'catalog_test_support.dart';

Future<String> hash(List<int> bytes) async {
  final digest = await Sha256().hash(bytes);
  return digest.bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('media installs atomically and missing files preserve the seed',
      () async {
    final root = await Directory.systemTemp.createTemp('poke-media-');
    try {
      final store = CatalogActiveStore(root);
      final oldBytes = Uint8List.fromList([1, 2, 3]);
      final newBytes = Uint8List.fromList([4, 5, 6, 7]);
      final oldHash = await hash(oldBytes);
      final newHash = await hash(newBytes);
      await createCatalog(store.seed, '1');
      await createCatalog(File('${root.path}/new.sqlite'), '1');
      for (final entry in [
        (store.seed, oldHash, oldBytes.length),
        (File('${root.path}/new.sqlite'), newHash, newBytes.length)
      ]) {
        final db = await openDatabase(entry.$1.path);
        await db.insert('media', {
          'asset_id': entry.$2,
          'relative_path': 'media/${entry.$2}.webp',
          'sha256': entry.$2,
          'bytes': entry.$3
        });
        await db.insert('pokemon', {'id': 1, 'normal_asset': entry.$2});
        await db.close();
      }
      final base = await stage(root, File('${root.path}/new.sqlite'));
      final media = CatalogFile('media/$newHash.webp', 'media-$newHash.webp',
          newBytes.length, newHash);
      final manifest = CatalogManifest(
          base.version, base.baseVersion, [...base.files, media]);
      final staging = Directory('${root.path}/staging');
      final partial = File('${staging.path}/${media.asset}.part');
      await partial.writeAsBytes(newBytes);
      await expectLater(CatalogInstaller(store).install(manifest, staging),
          throwsFormatException);
      expect(await store.activeVersion(), base.baseVersion);
      expect(await store.versionDirectory(base.version).exists(), isFalse);
      await File('${staging.path}/${media.asset}').writeAsBytes(newBytes);
      await CatalogInstaller(store).install(manifest, staging);
      final candidate =
          File('${store.versionDirectory(base.version).path}/catalog.sqlite');
      final db = await openDatabase(candidate.path, readOnly: true);
      final resolver =
          await CatalogMediaResolver.open(db, candidate, store.seed);
      final loaded =
          await resolver.load('assets/offline_catalog/normal/1.webp');
      expect(Uint8List.sublistView(loaded), newBytes);
      await db.close();
      await resolver
          .fileFor('assets/offline_catalog/normal/1.webp')!
          .writeAsBytes([0]);
      final damaged = await openDatabase(candidate.path, readOnly: true);
      await expectLater(
          CatalogMediaResolver.open(damaged, candidate, store.seed),
          throwsFormatException);
      await damaged.close();
      await store.recover(store.seed);
      expect(await store.activeVersion(), base.baseVersion);
    } finally {
      await root.delete(recursive: true);
    }
  });
}
