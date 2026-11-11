import 'dart:io';
import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokeapp_flutter/data/updates/catalog_downloader.dart';
import 'package:pokeapp_flutter/data/updates/catalog_manifest.dart';

Future<String> hash(List<int> bytes) async {
  final result = await Sha256().hash(bytes);
  return result.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

void main() {
  late Directory directory;
  setUp(() async => directory = await Directory.systemTemp.createTemp('poke-dl-'));
  tearDown(() async => directory.delete(recursive: true));

  test('downloads, verifies, and reuses a valid file', () async {
    final bytes = gzip.encode(utf8.encode('catalog'));
    final entry = CatalogFile('catalog.sqlite.gz', 'catalog.sqlite.gz',
      bytes.length, await hash(bytes));
    final manifest = CatalogManifest('2026.11.11', '2026.11.05', [entry]);
    var requests = 0;
    final client = MockClient((_) async {
      requests++;
      return http.Response.bytes(bytes, 200);
    });
    final downloader = CatalogDownloader(
      manifestUrl: Uri.parse('http://localhost/update-manifest.json'),
      client: client);
    await downloader.download(manifest, directory);
    await downloader.download(manifest, directory);
    expect(requests, 1);
    expect(await File('${directory.path}/catalog.sqlite.gz').readAsBytes(), bytes);
    client.close();
  });

  test('rejects a bad hash and removes partial download', () async {
    final bytes = utf8.encode('wrong content');
    final entry = CatalogFile('catalog.sqlite.gz', 'catalog.sqlite.gz',
      bytes.length, 'a' * 64);
    final client = MockClient((_) async => http.Response.bytes(bytes, 200));
    final downloader = CatalogDownloader(
      manifestUrl: Uri.parse('http://localhost/update-manifest.json'),
      client: client);
    await expectLater(downloader.download(
      CatalogManifest('2026.11.11', '2026.11.05', [entry]), directory),
      throwsFormatException);
    expect(await File('${directory.path}/catalog.sqlite.gz.part').exists(), false);
    client.close();
  });
}
