import 'dart:io';
import 'package:sqflite/sqflite.dart';

class CatalogSqliteValidator {
  Future<void> validate(File candidate) async {
    Database? database;
    try {
      database = await openDatabase(candidate.path,
          readOnly: true, singleInstance: false);
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
    } finally {
      await database?.close();
    }
  }
}
