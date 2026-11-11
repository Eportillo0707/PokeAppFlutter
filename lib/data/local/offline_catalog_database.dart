import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class OfflineCatalogDatabase {
  OfflineCatalogDatabase._(this.database, this.mp3CryIds);

  static const assetPath = 'assets/offline_catalog/catalog.sqlite.gz';
  static const fileName = 'catalog-v1.sqlite';
  final Database database;
  final Set<int> mp3CryIds;

  static Future<OfflineCatalogDatabase> open() async {
    final directory = await getDatabasesPath();
    final file = File('$directory${Platform.pathSeparator}$fileName');
    if (!await file.exists()) {
      await Directory(directory).create(recursive: true);
      final compressed = await rootBundle.load(assetPath);
      final bytes = await compute(
        _decompressCatalog,
        compressed.buffer.asUint8List(),
      );
      final temporary = File('${file.path}.tmp');
      await temporary.writeAsBytes(bytes, flush: true);
      await temporary.rename(file.path);
    }
    final database = await openDatabase(file.path);
    final version = await database.rawQuery(
      "SELECT value FROM catalog_meta WHERE key = 'schema_version'",
    );
    if (version.isNotEmpty && version.first['value'] != '1') {
      await database.close();
      throw StateError('Unsupported offline catalog schema');
    }
    final formats = await rootBundle.loadString(
      'assets/offline_catalog/cry_mp3_ids.json',
    );
    final mp3CryIds = (jsonDecode(formats) as List).cast<int>().toSet();
    return OfflineCatalogDatabase._(database, mp3CryIds);
  }

  Future<List<Map<String, Object?>>> query(
    String sql, [List<Object?> arguments = const []]) =>
      database.rawQuery(sql, arguments);

  Future<void> close() => database.close();
}

Uint8List _decompressCatalog(Uint8List bytes) =>
    Uint8List.fromList(gzip.decode(bytes));
