import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/data/local/offline_catalog_database.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/mega_stone_names.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/mega_stone_names_extra.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('every Mega form with a stone has its original bundled sprite',
      () async {
    final catalog = await OfflineCatalogDatabase.open();
    addTearDown(catalog.close);
    final rows = await catalog
        .query("SELECT name FROM pokemon WHERE name LIKE '%-mega%'");
    final stones = {...megaStoneNames, ...megaStoneNamesExtra};
    for (final row in rows) {
      final name = row['name'] as String;
      if (name == 'rayquaza-mega') continue;
      final stone = stones[name];
      expect(stone, isNotNull, reason: name);
      final data = await rootBundle.load('assets/offline_catalog/items/$stone');
      expect(data.lengthInBytes, greaterThan(0), reason: name);
    }
  });
}
