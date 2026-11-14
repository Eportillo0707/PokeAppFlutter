import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokeapp_flutter/data/updates/catalog_manifest.dart';
import 'package:pokeapp_flutter/data/updates/catalog_update_checker.dart';

void main() {
  const current = '2026.11.05';
  const update = CatalogManifest('2026.11.11', current, []);

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('checks once and waits 15 days after success', () async {
    var calls = 0;
    var now = DateTime.utc(2026, 11, 11);
    final checker = CatalogUpdateChecker(installedVersion: () async => current,
      now: () => now, fetch: () async { calls++; return update; });
    expect((await checker.check())?.version, update.version);
    expect(await checker.check(), isNull);
    expect(calls, 1);
    now = now.add(const Duration(days: 15));
    expect((await checker.check())?.version, update.version);
    expect(calls, 2);
  });

  test('manual check bypasses the interval', () async {
    var calls = 0;
    final checker = CatalogUpdateChecker(installedVersion: () async => current,
      now: () => DateTime.utc(2026, 11, 11),
      fetch: () async { calls++; return update; });
    await checker.check();
    await checker.check(manual: true);
    expect(calls, 2);
  });

  test('failed request does not update last success', () async {
    var calls = 0;
    var now = DateTime.utc(2026, 11, 11);
    final checker = CatalogUpdateChecker(installedVersion: () async => current,
      now: () => now, fetch: () async {
        calls++;
        if (calls == 1) throw StateError('offline');
        return update;
      });
    await expectLater(checker.check(), throwsStateError);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(CatalogUpdateChecker.lastSuccessKey), isNull);
    expect(await checker.check(), isNull);
    now = now.add(const Duration(hours: 1));
    expect((await checker.check())?.version, update.version);
  });

  test('rejects an update for another base version', () async {
    final checker = CatalogUpdateChecker(installedVersion: () async => current,
      fetch: () async => const CatalogManifest('2026.11.11', '2026.11.10', []));
    expect(await checker.check(manual: true), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(CatalogUpdateChecker.lastSuccessKey), isNull);
  });

  test('offers the latest catalog after intermediate versions were skipped',
      () async {
    const latest = CatalogManifest('2026.11.20', current, []);
    final checker = CatalogUpdateChecker(
      installedVersion: () async => '2026.11.13.2',
      fetch: () async => latest);
    expect(await checker.check(manual: true), latest);
  });
}
