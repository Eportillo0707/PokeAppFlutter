import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'catalog_manifest.dart';

class CatalogUpdateChecker {
  CatalogUpdateChecker({required this.fetch, required this.installedVersion,
    DateTime Function()? now}) : _now = now ?? DateTime.now;

  static const lastSuccessKey = 'catalog_update_last_success';
  static const lastAttemptKey = 'catalog_update_last_attempt';
  final Future<CatalogManifest> Function() fetch;
  final String installedVersion;
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
    await prefs.setString(lastSuccessKey, now.toIso8601String());
    if (_compare(manifest.version, installedVersion) <= 0) return null;
    if (manifest.baseVersion != installedVersion) return null;
    return manifest;
  }

  int _compare(String left, String right) {
    final a = left.split('.').map(int.parse).toList();
    final b = right.split('.').map(int.parse).toList();
    for (var i = 0; i < 4; i++) {
      final x = i < a.length ? a[i] : 0;
      final y = i < b.length ? b[i] : 0;
      if (x != y) return x.compareTo(y);
    }
    return 0;
  }
}
