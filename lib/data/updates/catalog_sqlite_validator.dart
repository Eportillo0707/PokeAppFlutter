import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';

class CatalogSqliteValidator {
  Future<void> validate(File candidate, File seed) async {
    final base = await openDatabase(seed.path, readOnly: true,
      singleInstance: false);
    Database? database;
    try {
      database = await openDatabase(candidate.path, readOnly: true,
        singleInstance: false);
      final integrity = await database.rawQuery('PRAGMA integrity_check');
      if (integrity.single.values.single != 'ok') {
        throw const FormatException('Catalog SQLite integrity failed');
      }
      final foreignKeys = await database.rawQuery('PRAGMA foreign_key_check');
      if (foreignKeys.isNotEmpty) {
        throw const FormatException('Catalog foreign keys failed');
      }
      final schema = await database.rawQuery(
        "SELECT value FROM catalog_meta WHERE key = 'schema_version'");
      if (schema.single['value'] != '1') {
        throw const FormatException('Unsupported catalog schema');
      }
      final oldMedia = await base.rawQuery('SELECT sha256 FROM media');
      final known = oldMedia.map((row) => row['sha256']).toSet();
      final newMedia = await database.rawQuery('SELECT sha256 FROM media');
      if (newMedia.any((row) => !known.contains(row['sha256']))) {
        throw const FormatException('Catalog requires new media');
      }
      for (final spec in [
        ('pokemon', 'id', 'normal_asset, shiny_asset, cry_asset'),
        ('evolution_items', 'item_name', 'asset_id'),
      ]) {
        final columns = '${spec.$2}, ${spec.$3}';
        final oldRows = await base.rawQuery(
          'SELECT $columns FROM ${spec.$1} ORDER BY ${spec.$2}');
        final newRows = await database.rawQuery(
          'SELECT $columns FROM ${spec.$1} ORDER BY ${spec.$2}');
        if (jsonEncode(oldRows) != jsonEncode(newRows)) {
          throw const FormatException('Catalog media mapping changed');
        }
      }
    } finally {
      await database?.close();
      await base.close();
    }
  }
}
