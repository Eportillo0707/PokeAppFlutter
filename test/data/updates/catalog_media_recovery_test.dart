import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pokeapp_flutter/data/updates/catalog_active_store.dart';
import 'package:pokeapp_flutter/data/updates/catalog_media_resolver.dart';
import 'catalog_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('damaged active media falls back to previous catalog', () async {
    final root = await Directory.systemTemp.createTemp('poke-recover-');
    try {
      final store = CatalogActiveStore(root);
      await createCatalog(store.seed, '1');
      final previous = store.versionDirectory('2026.11.11');
      final active = store.versionDirectory('2026.11.13');
      await previous.create(recursive: true);
      await active.create(recursive: true);
      final oldFile = File('${previous.path}/catalog.sqlite');
      final newFile = File('${active.path}/catalog.sqlite');
      await createCatalog(oldFile, '1');
      await createCatalog(newFile, '1');
      final bytes = [1, 2, 3, 4];
      final digest = await Sha256().hash(bytes);
      final hash =
          digest.bytes.map((n) => n.toRadixString(16).padLeft(2, '0')).join();
      final db = await openDatabase(newFile.path);
      await db.insert('media', {
        'asset_id': hash,
        'relative_path': 'media/$hash.webp',
        'sha256': hash,
        'bytes': bytes.length
      });
      await db.insert('pokemon', {'id': 1, 'normal_asset': hash});
      await db.close();
      await store.activate('2026.11.11');
      await store.activate('2026.11.13');
      File? selected;
      for (final candidate in await store.candidates()) {
        final opened = await openDatabase(candidate.path, readOnly: true);
        try {
          await CatalogMediaResolver.open(opened, candidate, store.seed);
          selected = candidate;
          break;
        } on FormatException {
          // The app tries the previous candidate after media validation fails.
        } finally {
          await opened.close();
        }
      }
      expect(selected?.path, oldFile.path);
      await store.recover(selected!);
      expect(await store.activeVersion(), '2026.11.11');
      expect(await active.exists(), isFalse);
    } finally {
      await root.delete(recursive: true);
    }
  });
}
