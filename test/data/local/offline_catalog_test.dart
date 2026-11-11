import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:pokeapp_flutter/data/local/offline_catalog_database.dart';
import 'package:pokeapp_flutter/data/local/offline_pokemon_repository.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_generation.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
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

  test('search, generation and type use the bundled catalog', () async {
    final first = await repository.getPokemonList(limit: 3);
    expect(first.map((p) => p.name), ['bulbasaur', 'ivysaur', 'venusaur']);
    expect(first.first.imageUrl, 'assets/offline_catalog/normal/1.webp');
    expect(
        (await repository.searchPokemon('char'))
            .any((p) => p.name == 'charizard'),
        isTrue);
    expect(
        (await repository.getPokemonByType('fire'))
            .any((p) => p.name == 'charizard'),
        isTrue);
    expect(
        (await repository.getPokemonByGeneration(pokemonGenerations[8],
                limit: 1))
            .first
            .id,
        906);
  });

  test('details, evolution, moves and media work without HTTP', () async {
    final info =
        await repository.getPokemonInfo('charizard', languageCode: 'es');
    expect(info.types, contains('fire'));
    expect(info.stats.map((stat) => stat.name), [
      'hp',
      'attack',
      'defense',
      'special-attack',
      'special-defense',
      'speed',
    ]);
    expect(info.description, isNotEmpty);
    expect(info.evolutionChain.any((p) => p.name == 'charmander'), isTrue);
    expect(info.evolutionChain.firstWhere((p) => p.name == 'charmander').types,
        contains('fire'));
    expect(
        info.megaEvolutions
            .firstWhere((p) => p.name == 'charizard-mega-x')
            .types,
        contains('dragon'));
    expect(info.moves.any((m) => m.learning.any((l) => l.game == 'champions')),
        isTrue);
    expect(info.shinyImageUrl, 'assets/offline_catalog/shiny/6.webp');
    expect(info.cryUrl, 'offline_catalog/cries/6.ogg');
    final saved = PokemonItem.fromJson({
      'id': 6,
      'name': 'charizard',
      'types': ['fire', 'flying']
    });
    expect(saved.imageUrl, info.imageUrl);
    final battle = await repository.getMoveBattleInfo(
        'dragon-claw', 'scarlet-violet', 'en');
    expect(battle.category, 'physical');
    expect(battle.power, 80);
    expect(
        (await repository.getMoveDescription(
                'dragon-claw', 'scarlet-violet', 'en'))
            ?.text,
        isNotEmpty);
    final vulpix =
        await repository.getPokemonInfo('vulpix', languageCode: 'es');
    final ninetales =
        vulpix.evolutionChain.firstWhere((p) => p.name == 'ninetales');
    expect(ninetales.evolutionMethod, 'Piedra Fuego');
    expect(ninetales.evolutionItemImageUrl,
        'assets/offline_catalog/items/fire-stone.webp');
    for (final path in [
      info.imageUrl,
      info.shinyImageUrl!,
      'assets/${info.cryUrl!}',
      ninetales.evolutionItemImageUrl!
    ]) {
      expect((await rootBundle.load(path)).lengthInBytes, greaterThan(0));
    }
    final mega = await repository.getPokemonInfo('venusaur-mega');
    expect(mega.cryUrl, 'offline_catalog/cries/10033.mp3');
    final mp3 = await rootBundle.load('assets/${mega.cryUrl!}');
    expect(mp3.getUint8(0), 0xff);
  });
}
