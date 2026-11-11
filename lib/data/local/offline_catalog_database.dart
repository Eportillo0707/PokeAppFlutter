import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pokeapp_flutter/data/updates/catalog_active_store.dart';
import 'offline_catalog_candidate.dart';

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
    final store = CatalogActiveStore(Directory(directory));
    final candidates = kReleaseMode ? [file] : await store.candidates();
    Database? database;
    File? selected;
    Object? lastError;
    for (final candidate in candidates) {
      if (!await candidate.exists()) continue;
      try {
        database = await openCatalogCandidate(candidate);
        selected = candidate;
        break;
      } catch (error) {
        lastError = error;
      }
    }
    if (database == null) throw StateError('No valid offline catalog: $lastError');
    if (!kReleaseMode && selected!.path != candidates.first.path) {
      try { await store.recover(selected); } catch (_) { /* Keep local access. */ }
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
