import 'dart:io';
import 'package:flutter/foundation.dart';

Future<void> decompressCatalog(File source, File target) =>
    compute(_decodeToFile, [source.path, target.path]);

Future<void> _decodeToFile(List<String> paths) async {
  final input = File(paths[0]);
  final output = File(paths[1]);
  IOSink? sink;
  try {
    sink = output.openWrite();
    var total = 0;
    await for (final chunk in gzip.decoder.bind(input.openRead())) {
      total += chunk.length;
      if (total > 268435456) {
        throw const FormatException('Catalog SQLite too large');
      }
      sink.add(chunk);
    }
    await sink.flush();
    await sink.close();
  } catch (_) {
    await sink?.close();
    if (await output.exists()) await output.delete();
    rethrow;
  }
}
