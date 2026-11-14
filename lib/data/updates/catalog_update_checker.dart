import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'catalog_manifest.dart';
import 'catalog_version.dart';

class CatalogUpdateChecker {
  CatalogUpdateChecker({required this.fetch, required this.installedVersion,
    DateTime Function()? now}) : _now = now ?? DateTime.now;

  static const lastSuccessKey = 'catalog_update_last_success';
  static const lastAttemptKey = 'catalog_update_last_attempt';
  final Future<CatalogManifest> Function() fetch;
  final Future<String> Function() installedVersion;
  final DateTime Function() _now;
  Future<CatalogManifest?>? _pending;

  Future<CatalogManifest?> check({bool manual = false}) =>
      _pending ??= _run(manual).whenComplete(() => _pending = null);

  Future<CatalogManifest?> _run(bool manual) async {
    final prefs = await SharedPreferences.getInstance();
    final now = _now().toUtc();
    if (!manual) {
      final success = DateTime.tryParse(prefs.getString(lastSuccessKey) ?? '');
      final attempt = DateTime.tryParse(prefs.getString(lastAttemptKey) ?? '');
      if (success != null && now.difference(success).inDays < 15) return null;
      if (attempt != null && now.difference(attempt).inMinutes < 60) return null;
    }
    await prefs.setString(lastAttemptKey, now.toIso8601String());
    final manifest = await fetch();
    final current = await installedVersion();
    if (compareCatalogVersions(manifest.baseVersion, current) > 0) return null;
    await prefs.setString(lastSuccessKey, now.toIso8601String());
    if (compareCatalogVersions(manifest.version, current) <= 0) return null;
    return manifest;
  }

}
