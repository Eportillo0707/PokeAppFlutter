import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pokeapp_flutter/data/updates/catalog_manifest.dart';

Future<void> createCatalog(File file, String schema, {String? marker}) async {
  final db = await openDatabase(file.path);
  await db.execute('CREATE TABLE catalog_meta (key TEXT, value TEXT)');
  await db.insert('catalog_meta', {'key': 'schema_version', 'value': schema});
  if (marker != null) {
    await db.insert('catalog_meta', {'key': 'marker', 'value': marker});
  }
  await db.execute('CREATE TABLE media (asset_id TEXT, relative_path TEXT, '
      'sha256 TEXT, bytes INTEGER)');
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
  final hex =
      digest.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return CatalogManifest('2026.11.11', '2026.11.05', [
    CatalogFile('catalog.sqlite.gz', 'catalog.sqlite.gz', bytes.length, hex),
  ]);
}
