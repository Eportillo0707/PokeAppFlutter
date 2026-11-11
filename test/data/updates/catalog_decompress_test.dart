import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/data/updates/catalog_decompress.dart';

void main() {
  test('corrupt gzip leaves no SQLite file', () async {
    final directory = await Directory.systemTemp.createTemp('poke-gzip-');
    try {
      final source = File('${directory.path}/bad.gz');
      final target = File('${directory.path}/catalog.sqlite');
      await source.writeAsBytes([1, 2, 3, 4]);
      await expectLater(decompressCatalog(source, target), throwsFormatException);
      expect(await target.exists(), false);
    } finally {
      await directory.delete(recursive: true);
    }
  });
}
