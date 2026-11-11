import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pokeapp_flutter/data/updates/catalog_active_store.dart';
import 'package:pokeapp_flutter/data/updates/catalog_installer.dart';
import 'package:pokeapp_flutter/data/updates/catalog_manifest.dart';

Future<void> createCatalog(File file, String schema) async {
  final db = await openDatabase(file.path);
  await db.execute('CREATE TABLE catalog_meta (key TEXT, value TEXT)');
  await db.insert('catalog_meta', {'key': 'schema_version', 'value': schema});
  await db.execute('CREATE TABLE media (sha256 TEXT)');
  await db.execute('CREATE TABLE pokemon (id INTEGER, normal_asset TEXT, '
    'shiny_asset TEXT, cry_asset TEXT)');
  await db.execute('CREATE TABLE evolution_items '
    '(item_name TEXT, asset_id TEXT)');
  await db.close();
}

Future<CatalogManifest> stage(Directory directory, File catalog) async {
  final bytes = gzip.encode(await catalog.readAsBytes());
  final staging = Directory('${directory.path}/staging');
  await staging.create();
  await File('${staging.path}/catalog.sqlite.gz').writeAsBytes(bytes);
  final digest = await Sha256().hash(bytes);
  final hex = digest.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return CatalogManifest('2026.11.11', '2026.11.05', [
    CatalogFile('catalog.sqlite.gz', 'catalog.sqlite.gz', bytes.length, hex),
  ]);
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  late Directory directory;
  setUp(() async => directory = await Directory.systemTemp.createTemp('poke-install-'));
  tearDown(() async => directory.delete(recursive: true));

  test('activates a valid catalog and keeps the seed', () async {
    final store = CatalogActiveStore(directory);
    await createCatalog(store.seed, '1');
    final source = File('${directory.path}/new.sqlite');
    await createCatalog(source, '1');
    final manifest = await stage(directory, source);
    await expectLater(CatalogInstaller(store).install(
      CatalogManifest('2026.11.04', '2026.11.05', manifest.files),
      Directory('${directory.path}/staging')), throwsFormatException);
    await CatalogInstaller(store).install(manifest,
      Directory('${directory.path}/staging'));
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
    await expectLater(CatalogInstaller(store).install(manifest,
      Directory('${directory.path}/staging')), throwsFormatException);
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
    await db.insert('media', {'sha256': 'a' * 64});
    await db.close();
    final manifest = await stage(directory, source);
    await expectLater(CatalogInstaller(store).install(manifest,
      Directory('${directory.path}/staging')), throwsFormatException);
    expect(await store.activeVersion(), '2026.11.05');
  });
}
