import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/data/updates/catalog_active_store.dart';

void main() {
  test('keeps the previous catalog when activating another version', () async {
    final root = await Directory.systemTemp.createTemp('poke-pointer-');
    try {
      final store = CatalogActiveStore(root);
      for (final version in ['2026.11.11', '2026.11.12']) {
        final folder = store.versionDirectory(version);
        await folder.create(recursive: true);
        await File('${folder.path}/catalog.sqlite').writeAsString(version);
        await store.activate(version);
      }
      expect(await store.activeVersion(), '2026.11.12');
      final candidates = await store.candidates();
      expect(candidates[0].path, contains('2026.11.12'));
      expect(candidates[1].path, contains('2026.11.11'));
    } finally {
      await root.delete(recursive: true);
    }
  });
}
