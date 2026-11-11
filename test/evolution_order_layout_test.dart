import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/data/local/offline_catalog_database.dart';
import 'package:pokeapp_flutter/data/local/offline_pokemon_repository.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_item.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_section.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late OfflineCatalogDatabase catalog;
  late OfflinePokemonRepository repository;
  setUpAll(() async {
    catalog = await OfflineCatalogDatabase.open();
    repository = OfflinePokemonRepository(catalog);
  });
  tearDownAll(() async => catalog.close());

  test('pre evolutions precede older Pokédex IDs', () async {
    final pikachu = await repository.getPokemonInfo('pikachu');
    expect(
        pikachu.evolutionChain
            .where((p) => !p.name.contains('-mega'))
            .map((p) => p.name)
            .toList(),
        ['pichu', 'pikachu', 'raichu']);
    final mime = await repository.getPokemonInfo('mr-mime');
    final names = mime.evolutionChain.map((p) => p.name).toList();
    expect(names.indexOf('mime-jr'), lessThan(names.indexOf('mr-mime')));
    expect(names.indexOf('mr-mime'), lessThan(names.indexOf('mr-rime')));
  });

  testWidgets('regional cards keep visible gaps', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const forms = [
      PokemonSpecies(id: 37, name: 'vulpix-alola'),
      PokemonSpecies(id: 38, name: 'ninetales-alola'),
    ];
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: EvolutionSection(
                title: 'Regional forms',
                species: forms,
                showArrows: false,
                currentPokemonId: 1,
                onSpeciesTap: (_) {}))));
    await tester.pumpAndSettle();
    final cards = find.byType(EvolutionItem);
    expect(cards, findsNWidgets(2));
    final left = tester.getRect(cards.at(0));
    final right = tester.getRect(cards.at(1));
    expect(right.left - left.right, greaterThanOrEqualTo(8));
    expect(tester.takeException(), isNull);
  });
}
