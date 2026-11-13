import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

Future<Map<String, String>> bundledCryFormats(Database seed) async {
  final raw =
      await rootBundle.loadString('assets/offline_catalog/cry_mp3_ids.json');
  final mp3Ids = (jsonDecode(raw) as List).cast<int>().toSet();
  final rows = await seed.rawQuery('SELECT id, cry_asset FROM pokemon');
  return {
    for (final row in rows)
      if (mp3Ids.contains(row['id']) && row['cry_asset'] is String)
        row['cry_asset'] as String: 'mp3',
  };
}
