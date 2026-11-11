import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;
import 'catalog_manifest.dart';

class CatalogManifestClient {
  CatalogManifestClient({required this.url, required this.publicKey,
    http.Client? client}) : _client = client ?? http.Client();

  final Uri url;
  final List<int> publicKey;
  final http.Client _client;

  Future<CatalogManifest> fetch() async {
    if (publicKey.length != 32 ||
        (url.scheme != 'https' && url.host != 'localhost' &&
            url.host != '127.0.0.1')) {
      throw const FormatException('Invalid update configuration');
    }
    final manifest = await _client.get(url).timeout(const Duration(seconds: 10));
    final signature = await _client.get(url.resolve('update-manifest.sig'))
        .timeout(const Duration(seconds: 10));
    if (manifest.statusCode != 200 || signature.statusCode != 200 ||
        manifest.bodyBytes.length > 1048576 || signature.bodyBytes.length > 512) {
      throw const FormatException('Manifest download failed');
    }
    final bytes = base64Decode(signature.body.trim());
    final verified = await Ed25519().verify(manifest.bodyBytes,
      signature: Signature(bytes, publicKey:
        SimplePublicKey(publicKey, type: KeyPairType.ed25519)));
    if (!verified) throw const FormatException('Invalid catalog signature');
    return CatalogManifest.fromJson(
      jsonDecode(utf8.decode(manifest.bodyBytes)) as Map<String, dynamic>);
  }

  void close() => _client.close();
}
