import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/data/local/offline_catalog_database.dart';
import 'package:pokeapp_flutter/data/local/offline_pokemon_repository.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_routes.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('offline Applin branches keep their own evolution methods', () async {
    final catalog = await OfflineCatalogDatabase.open();
    addTearDown(catalog.close);
    final info =
        await OfflinePokemonRepository(catalog).getPokemonInfo('applin');
    final routes = evolutionRoutes(info.evolutionChain);
    expect(
        routes.map((route) => route.map((item) => item.name).toList()).toList(),
        [
          ['applin', 'flapple'],
          ['applin', 'appletun'],
          ['applin', 'dipplin', 'hydrapple'],
        ]);
    expect(routes.map((route) => route.last.evolutionMethod),
        everyElement(isNotNull));
  });
}
