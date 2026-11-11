import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'catalog_manifest.dart';
import 'catalog_manifest_client.dart';
import 'catalog_update_checker.dart';

class CatalogUpdateService extends ChangeNotifier {
  CatalogUpdateService._(this._client, this._checker);

  static CatalogUpdateService? fromEnvironment() {
    const url = String.fromEnvironment('POKEAPP_CATALOG_MANIFEST_URL');
    const key = String.fromEnvironment('POKEAPP_CATALOG_PUBLIC_KEY');
    if (kReleaseMode || url.isEmpty || key.isEmpty) return null;
    try {
      final client = CatalogManifestClient(
        url: Uri.parse(url), publicKey: base64Decode(key));
      final checker = CatalogUpdateChecker(fetch: client.fetch,
        installedVersion: '2026.11.05');
      return CatalogUpdateService._(client, checker);
    } on FormatException {
      return null;
    }
  }

  final CatalogManifestClient _client;
  final CatalogUpdateChecker _checker;
  CatalogManifest? available;
  Object? error;
  bool checking = false;
  bool _disposed = false;

  Future<void> check({bool manual = false}) async {
    if (checking) return;
    checking = true;
    error = null;
    notifyListeners();
    try {
      available = await _checker.check(manual: manual);
    } catch (caught) {
      error = caught;
    } finally {
      checking = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _client.close();
    super.dispose();
  }
}
