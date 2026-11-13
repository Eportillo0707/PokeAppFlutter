import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'catalog_active_store.dart';
import 'catalog_update_access.dart';
import 'catalog_downloader.dart';
import 'catalog_installer.dart';
import 'catalog_manifest.dart';
import 'catalog_manifest_client.dart';
import 'catalog_update_checker.dart';

class CatalogUpdateService extends ChangeNotifier {
  CatalogUpdateService._(this._client, this._checker);

  static CatalogUpdateService? fromEnvironment() {
    const url = String.fromEnvironment('POKEAPP_CATALOG_MANIFEST_URL');
    const key = String.fromEnvironment('POKEAPP_CATALOG_PUBLIC_KEY');
    if (!catalogUpdateAccess || url.isEmpty || key.isEmpty) return null;
    try {
      final client = CatalogManifestClient(
        url: Uri.parse(url), publicKey: base64Decode(key));
      final checker = CatalogUpdateChecker(fetch: client.fetch,
        installedVersion: () async => (await _store()).activeVersion());
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
  bool installing = false;
  bool restartRequired = false;
  int downloadedBytes = 0;
  bool _disposed = false;

  static Future<CatalogActiveStore> _store() async =>
      CatalogActiveStore(Directory(await getDatabasesPath()));

  Future<String> installedVersion() async => (await _store()).activeVersion();

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

  Future<void> installAvailable() async {
    final manifest = available;
    if (manifest == null || installing) return;
    installing = true;
    error = null;
    downloadedBytes = 0;
    notifyListeners();
    final client = http.Client();
    try {
      final store = await _store();
      final staging = Directory('${store.root.path}/staging/${manifest.version}');
      await CatalogDownloader(manifestUrl: _client.url, client: client)
          .download(manifest, staging, onProgress: (done, _) {
        downloadedBytes = done;
        if (!_disposed) notifyListeners();
      });
      await CatalogInstaller(store).install(manifest, staging);
      available = null;
      restartRequired = true;
    } catch (caught) {
      error = caught;
    } finally {
      client.close();
      installing = false;
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
