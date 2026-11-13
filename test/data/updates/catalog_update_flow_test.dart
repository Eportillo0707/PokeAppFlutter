import 'dart:convert';
import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pokeapp_flutter/data/local/offline_catalog_candidate.dart';
import 'package:pokeapp_flutter/data/updates/catalog_active_store.dart';
import 'package:pokeapp_flutter/data/updates/catalog_downloader.dart';
import 'package:pokeapp_flutter/data/updates/catalog_installer.dart';
import 'package:pokeapp_flutter/data/updates/catalog_manifest_client.dart';
import 'catalog_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('signed download activates SQLite and preserves personal data',
      () async {
    final root = await Directory.systemTemp.createTemp('poke-flow-');
    try {
      SharedPreferences.setMockInitialValues({
        'favorite_pokemon': '[{"id":6}]',
        'pokemon_teams_v1': '[{"id":"team"}]',
      });
      final store = CatalogActiveStore(root);
      await createCatalog(store.seed, '1', marker: 'original');
      final next = File('${root.path}/next.sqlite');
      await createCatalog(next, '1', marker: 'updated');
      final bytes = gzip.encode(await next.readAsBytes());
      final digest = await Sha256().hash(bytes);
      final hash =
          digest.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      final manifestBytes = utf8.encode(jsonEncode({
        'formatVersion': 1,
        'schemaVersion': 1,
        'channel': 'offlinetest',
        'minAppVersion': '1.1.0',
        'catalogVersion': '2026.11.11',
        'baseCatalogVersion': '2026.11.05',
        'files': [
          {
            'path': 'catalog.sqlite.gz',
            'asset': 'catalog.sqlite.gz',
            'bytes': bytes.length,
            'sha256': hash
          }
        ],
      }));
      final pair = await Ed25519().newKeyPair();
      final key = await pair.extractPublicKey();
      final signature = await Ed25519().sign(manifestBytes, keyPair: pair);
      final httpClient = MockClient((request) async {
        if (request.url.path.endsWith('.sig')) {
          return http.Response(base64Encode(signature.bytes), 200);
        }
        if (request.url.path.endsWith('.gz')) {
          return http.Response.bytes(bytes, 200);
        }
        return http.Response.bytes(manifestBytes, 200);
      });
      final url = Uri.parse('http://localhost/update-manifest.json');
      final manifest = await CatalogManifestClient(
              url: url, publicKey: key.bytes, client: httpClient)
          .fetch();
      final staging = Directory('${root.path}/staging');
      await CatalogDownloader(manifestUrl: url, client: httpClient)
          .download(manifest, staging);
      await CatalogInstaller(store).install(manifest, staging);
      final db = await openCatalogCandidate((await store.candidates()).first);
      expect(
          (await db.rawQuery(
                  "SELECT value FROM catalog_meta WHERE key = 'marker'"))
              .single['value'],
          'updated');
      await db.close();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('favorite_pokemon'), contains('6'));
      expect(prefs.getString('pokemon_teams_v1'), contains('team'));
      httpClient.close();
    } finally {
      await root.delete(recursive: true);
    }
  });
}
