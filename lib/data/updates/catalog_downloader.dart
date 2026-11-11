import 'dart:io';
import 'package:http/http.dart' as http;
import 'catalog_file_verifier.dart';
import 'catalog_manifest.dart';

class CatalogDownloader {
  CatalogDownloader({required this.manifestUrl, required this.client,
    CatalogFileVerifier? verifier}) : verifier = verifier ?? CatalogFileVerifier();

  final Uri manifestUrl;
  final http.Client client;
  final CatalogFileVerifier verifier;

  Future<void> download(CatalogManifest manifest, Directory staging,
      {void Function(int, int)? onProgress}) async {
    await staging.create(recursive: true);
    var completed = 0;
    for (final entry in manifest.files) {
      if (entry.bytes > 67108864) {
        throw const FormatException('Catalog file too large');
      }
      final target = File('${staging.path}${Platform.pathSeparator}${entry.asset}');
      if (!await verifier.matches(target, entry)) {
        if (await target.exists()) await target.delete();
        await _download(entry, target, (received) =>
          onProgress?.call(completed + received, manifest.downloadBytes));
      }
      completed += entry.bytes;
      onProgress?.call(completed, manifest.downloadBytes);
    }
  }

  Future<void> _download(CatalogFile entry, File target,
      void Function(int) onProgress) async {
    final url = manifestUrl.resolve(entry.asset);
    if (url.scheme != 'https' && url.host != 'localhost' &&
        url.host != '127.0.0.1') {
      throw const FormatException('Unsafe download URL');
    }
    final partial = File('${target.path}.part');
    IOSink? sink;
    try {
      final request = http.Request('GET', url);
      final response = await client.send(request)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw HttpException('Catalog download failed: ${response.statusCode}');
      }
      sink = partial.openWrite();
      var received = 0;
      await for (final chunk in response.stream
          .timeout(const Duration(seconds: 30))) {
        received += chunk.length;
        if (received > entry.bytes) throw const FormatException('File too large');
        sink.add(chunk);
        onProgress(received);
      }
      await sink.flush();
      await sink.close();
      sink = null;
      if (!await verifier.matches(partial, entry)) {
        throw const FormatException('Catalog file hash mismatch');
      }
      await partial.rename(target.path);
    } catch (_) {
      await sink?.close();
      if (await partial.exists()) await partial.delete();
      rethrow;
    }
  }
}
