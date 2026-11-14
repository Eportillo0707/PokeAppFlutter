import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pokeapp_flutter/data/updates/catalog_active_store.dart';
import 'package:pokeapp_flutter/data/updates/catalog_installer.dart';
import 'package:pokeapp_flutter/data/updates/catalog_manifest.dart';
import 'catalog_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('installs the latest catalog after skipping intermediate versions',
      () async {
    final root = await Directory.systemTemp.createTemp('poke-skip-');
    try {
      final store = CatalogActiveStore(root);
      await createCatalog(store.seed, '1');
      final intermediate = store.versionDirectory('2026.11.11');
      await intermediate.create(recursive: true);
      await createCatalog(File('${intermediate.path}/catalog.sqlite'), '1');
      await store.activate('2026.11.11');
      final source = File('${root.path}/latest.sqlite');
      await createCatalog(source, '1', marker: 'latest');
      final staged = await stage(root, source);
      final latest = CatalogManifest('2026.11.20', '2026.11.05', staged.files);
      await CatalogInstaller(store).install(
          latest, Directory('${root.path}/staging'));
      expect(await store.activeVersion(), '2026.11.20');
      expect((await store.candidates())[1].path,
          '${intermediate.path}/catalog.sqlite');
    } finally {
      await root.delete(recursive: true);
    }
  });

  test('downloads media needed after skipping versions', () async {
    final root = await Directory.systemTemp.createTemp('poke-skip-media-');
    try {
      final store = CatalogActiveStore(root);
      await createCatalog(store.seed, '1');
      final intermediate = store.versionDirectory('2026.11.11');
      await intermediate.create(recursive: true);
      await createCatalog(File('${intermediate.path}/catalog.sqlite'), '1');
      await store.activate('2026.11.11');
      final source = File('${root.path}/latest.sqlite');
      await createCatalog(source, '1');
      final bytes = [1, 2, 3, 4];
      final digest = await Sha256().hash(bytes);
      final hash = digest.bytes
          .map((value) => value.toRadixString(16).padLeft(2, '0')).join();
      final db = await openDatabase(source.path);
      await db.insert('media', {'asset_id': hash,
        'relative_path': 'media/$hash.webp', 'sha256': hash,
        'bytes': bytes.length});
      await db.insert('pokemon', {'id': 1, 'normal_asset': hash});
      await db.close();
      final staged = await stage(root, source);
      await File('${root.path}/staging/media-$hash.webp').writeAsBytes(bytes);
      final latest = CatalogManifest('2026.11.20', '2026.11.05', [
        ...staged.files,
        CatalogFile('media/$hash.webp', 'media-$hash.webp', bytes.length, hash)
      ]);
      await CatalogInstaller(store).install(
          latest, Directory('${root.path}/staging'));
      expect(await store.activeVersion(), '2026.11.20');
      expect(await File('${store.versionDirectory(latest.version).path}'
          '/media/$hash.webp').readAsBytes(), bytes);
    } finally {
      await root.delete(recursive: true);
    }
  });
}
