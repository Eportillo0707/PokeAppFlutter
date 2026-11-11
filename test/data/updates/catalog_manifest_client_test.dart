import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokeapp_flutter/data/updates/catalog_manifest_client.dart';

void main() {
  test('verifies an Ed25519 signature produced by Node', () async {
    final publicKey = base64Decode(
      'ROprwVs7wNtqCiAGwPSAzfmQepAClbOcyhRywhh5W+U=');
    final signature = base64Decode(
      'cPKr6gzcTQWvRtUe27BlfLQfazOGMG+8nEdhgvYdXvOC12paT65p4wr2tvZn4al78CNXR6AZ9Btu3CDs7+FMAw==');
    expect(await Ed25519().verify(utf8.encode('catalog-signature-test'),
      signature: Signature(signature, publicKey:
        SimplePublicKey(publicKey, type: KeyPairType.ed25519))), isTrue);
  });

  const fileHash = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
  final payload = utf8.encode(jsonEncode({
    'formatVersion': 1, 'schemaVersion': 1, 'channel': 'offlinetest',
    'minAppVersion': '1.1.0', 'catalogVersion': '2026.11.11',
    'baseCatalogVersion': '2026.11.05',
    'files': [{'path': 'catalog.sqlite.gz', 'bytes': 100, 'sha256': fileHash}],
  }));

  test('accepts a signed test manifest', () async {
    final keyPair = await Ed25519().newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    final signature = await Ed25519().sign(payload, keyPair: keyPair);
    final client = CatalogManifestClient(
      url: Uri.parse('http://localhost/update-manifest.json'),
      publicKey: publicKey.bytes,
      client: MockClient((request) async => request.url.path.endsWith('.sig')
        ? http.Response(base64Encode(signature.bytes), 200)
        : http.Response.bytes(payload, 200)),
    );
    final manifest = await client.fetch();
    expect(manifest.version, '2026.11.11');
    expect(manifest.downloadBytes, 100);
    client.close();
  });

  test('rejects a tampered manifest', () async {
    final keyPair = await Ed25519().newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    final signature = await Ed25519().sign(payload, keyPair: keyPair);
    final client = CatalogManifestClient(
      url: Uri.parse('http://localhost/update-manifest.json'),
      publicKey: publicKey.bytes,
      client: MockClient((request) async => request.url.path.endsWith('.sig')
        ? http.Response(base64Encode(signature.bytes), 200)
        : http.Response.bytes([...payload, 32], 200)),
    );
    await expectLater(client.fetch(), throwsFormatException);
    client.close();
  });

  test('rejects an HTTP failure', () async {
    final keyPair = await Ed25519().newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    final client = CatalogManifestClient(
      url: Uri.parse('http://localhost/update-manifest.json'),
      publicKey: publicKey.bytes,
      client: MockClient((_) async => http.Response('unavailable', 503)),
    );
    await expectLater(client.fetch(), throwsFormatException);
    client.close();
  });
}
