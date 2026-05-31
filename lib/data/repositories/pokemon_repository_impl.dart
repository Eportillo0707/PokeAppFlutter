import 'package:pokeapp_flutter/data/remote/mappers/pokemon_mapper.dart';
import 'package:pokeapp_flutter/data/remote/pokemon_remote_data_source.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_generation.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  const PokemonRepositoryImpl({
    required PokemonRemoteDataSource remoteDataSource,
    required PokemonMapper mapper,
  })  : _remoteDataSource = remoteDataSource,
        _mapper = mapper;

  final PokemonRemoteDataSource _remoteDataSource;
  final PokemonMapper _mapper;

  @override
  Future<List<PokemonItem>> getPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _remoteDataSource.getPokemonList(
      limit: limit,
      offset: offset,
    );
    final results = List<Map<String, dynamic>>.from(data['results'] as List);
    final items = await Future.wait(
      results.map((item) => getPokemonItem(item['name'] as String)),
    );
    items.sort((a, b) => a.id.compareTo(b.id));
    return items;
  }

  @override
  Future<List<PokemonItem>> searchPokemon(String query) async {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return [];
    try {
      return [await getPokemonItem(trimmed)];
    } catch (_) {
      final data = await _remoteDataSource.getAllPokemonNames();
      final results = List<Map<String, dynamic>>.from(data['results'] as List);
      final matches = results
          .where((item) => (item['name'] as String).contains(trimmed))
          .take(40)
          .toList();
      return Future.wait(matches.map((item) => getPokemonItem(item['name'])));
    }
  }

  @override
  Future<List<PokemonItem>> getPokemonByType(String type) async {
    final data = await _remoteDataSource.getPokemonByType(type);
    final pokemon = List<Map<String, dynamic>>.from(data['pokemon'] as List);
    final items = await Future.wait(
      pokemon.map((slot) => getPokemonItem(slot['pokemon']['name'] as String)),
    );
    items.sort((a, b) => a.id.compareTo(b.id));
    return items;
  }

  @override
  Future<List<PokemonItem>> getPokemonByGeneration(
    PokemonGeneration generation,
  ) async {
    final ids = List<int>.generate(
      generation.endId - generation.startId + 1,
      (index) => generation.startId + index,
    );
    final items = await Future.wait(
      ids.map((id) => getPokemonItem('$id')),
    );
    items.sort((a, b) => a.id.compareTo(b.id));
    return items;
  }

  @override
  Future<PokemonItem> getPokemonItem(String name) async {
    final detail = await _remoteDataSource.getPokemon(name);
    return _mapper.mapPokemonItem(detail);
  }

  @override
  Future<PokemonInfo> getPokemonInfo(
    String name, {
    String languageCode = 'en',
  }) async {
    final pokemon = await _remoteDataSource.getPokemon(name);
    final species = await _getSpeciesOrNull(pokemon);
    final evolutionChain = await _getEvolutionChainOrNull(species);
    final normalEvolutions = _mapper.mapEvolutionSpecies(
      evolutionChain,
      languageCode: languageCode,
    );
    final megaEvolutions = await _getMegaEvolutions(
      normalEvolutions,
      languageCode,
    );
    final abilityDtos = await _getAbilities(pokemon);

    return _mapper.mapPokemonInfo(
      pokemon: pokemon,
      species: species,
      evolutionChain: evolutionChain,
      abilities: abilityDtos,
      megaEvolutions: megaEvolutions,
      languageCode: languageCode,
    );
  }

  Future<Map<String, dynamic>?> _getSpeciesOrNull(
    Map<String, dynamic> pokemon,
  ) async {
    try {
      return await _remoteDataSource.getPokemonSpecies(
        pokemon['species']['name'] as String,
      );
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getEvolutionChainOrNull(
    Map<String, dynamic>? species,
  ) async {
    try {
      final url = species?['evolution_chain']?['url'] as String?;
      if (url == null) return null;
      return await _remoteDataSource.getAbsoluteJson(url);
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _getAbilities(
    Map<String, dynamic> pokemon,
  ) async {
    final abilities = await Future.wait(
      List<Map<String, dynamic>>.from(pokemon['abilities'] as List).map(
        (slot) async {
          try {
            return await _remoteDataSource.getAbility(
              slot['ability']['name'] as String,
            );
          } catch (_) {
            return null;
          }
        },
      ),
    );
    return abilities.whereType<Map<String, dynamic>>().toList();
  }

  Future<List<PokemonSpecies>> _getMegaEvolutions(
    List<PokemonSpecies> baseSpecies,
    String languageCode,
  ) async {
    final all = <PokemonSpecies>[];
    for (final base in baseSpecies) {
      try {
        final species = await _remoteDataSource.getPokemonSpecies(base.name);
        final varieties = List<Map<String, dynamic>>.from(
          species['varieties'] as List? ?? [],
        );
        for (final variety in varieties) {
          final varietyName = variety['pokemon']['name'] as String;
          if (!varietyName.toLowerCase().contains('-mega')) continue;
          final detail = await _remoteDataSource.getPokemon(varietyName);
          all.add(
            PokemonSpecies(
              id: detail['id'] as int,
              name: detail['name'] as String,
              evolvesFromSpeciesId: base.id,
              evolutionMethod:
                  languageCode == 'es' ? 'Megaevolucion' : 'Mega Evolution',
            ),
          );
        }
      } catch (_) {}
    }
    all.sort((a, b) => a.id.compareTo(b.id));
    return _mapper.distinctSpecies(all);
  }
}
