import 'dart:io';
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
  late Directory directory;
  setUp(() async =>
      directory = await Directory.systemTemp.createTemp('poke-install-'));
  tearDown(() async => directory.delete(recursive: true));

  test('activates a valid catalog and keeps the seed', () async {
    final store = CatalogActiveStore(directory);
    await createCatalog(store.seed, '1');
    final source = File('${directory.path}/new.sqlite');
    await createCatalog(source, '1');
    final manifest = await stage(directory, source);
    await expectLater(
        CatalogInstaller(store).install(
            CatalogManifest('2026.11.04', '2026.11.05', manifest.files),
            Directory('${directory.path}/staging')),
        throwsFormatException);
    await CatalogInstaller(store)
        .install(manifest, Directory('${directory.path}/staging'));
    expect(await store.activeVersion(), '2026.11.11');
    expect(await store.seed.exists(), isTrue);
    expect((await store.candidates()).first.existsSync(), isTrue);
  });

  test('rejects an incompatible catalog without activating it', () async {
    final store = CatalogActiveStore(directory);
    await createCatalog(store.seed, '1');
    final source = File('${directory.path}/new.sqlite');
    await createCatalog(source, '2');
    final manifest = await stage(directory, source);
    await expectLater(
        CatalogInstaller(store)
            .install(manifest, Directory('${directory.path}/staging')),
        throwsFormatException);
    expect(await store.activeVersion(), '2026.11.05');
    expect(await store.seed.exists(), isTrue);
  });

  test('recovers the bundled seed after a damaged active version', () async {
    final store = CatalogActiveStore(directory);
    await createCatalog(store.seed, '1');
    final version = store.versionDirectory('2026.11.11');
    await version.create(recursive: true);
    await File('${version.path}/catalog.sqlite').writeAsString('damaged');
    await store.activate('2026.11.11');
    await store.recover(store.seed);
    expect(await store.activeVersion(), '2026.11.05');
    expect((await store.candidates()).single.path, store.seed.path);
  });

  test('rejects a catalog that needs uninstalled media', () async {
    final store = CatalogActiveStore(directory);
    await createCatalog(store.seed, '1');
    final source = File('${directory.path}/new.sqlite');
    await createCatalog(source, '1');
    final db = await openDatabase(source.path);
    await db.insert('media', {
      'asset_id': 'a' * 64,
      'relative_path': 'media/${'a' * 64}.webp',
      'sha256': 'a' * 64,
      'bytes': 8
    });
    await db.insert('pokemon', {'id': 1, 'normal_asset': 'a' * 64});
    await db.close();
    final manifest = await stage(directory, source);
    await expectLater(
        CatalogInstaller(store)
            .install(manifest, Directory('${directory.path}/staging')),
        throwsFormatException);
    expect(await store.activeVersion(), '2026.11.05');
  });
}
