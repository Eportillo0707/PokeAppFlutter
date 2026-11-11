import 'dart:io';
import 'package:sqflite/sqflite.dart';

Future<Database> openCatalogCandidate(File file) async {
  final database = await openDatabase(file.path);
  try {
    final schema = await database.rawQuery(
      "SELECT value FROM catalog_meta WHERE key = 'schema_version'");
    if (schema.isEmpty || schema.first['value'] != '1') {
      throw StateError('Unsupported offline catalog schema');
    }
    final check = await database.rawQuery('PRAGMA quick_check');
    if (check.single.values.single != 'ok') {
      throw StateError('Offline catalog failed integrity check');
    }
    return database;
  } catch (_) {
    await database.close();
    rethrow;
  }
}
