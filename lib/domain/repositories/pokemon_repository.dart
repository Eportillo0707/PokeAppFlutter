import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_generation.dart';

abstract class PokemonRepository {
  Future<List<PokemonItem>> getPokemonList({int limit = 20, int offset = 0});

  Future<List<PokemonItem>> searchPokemon(String query);

  Future<List<PokemonItem>> getPokemonByType(String type);

  Future<List<PokemonItem>> getPokemonByGeneration(
    PokemonGeneration generation, {
    int limit = 20,
    int offset = 0,
  });

  Future<PokemonItem> getPokemonItem(String name);

  Future<PokemonInfo> getPokemonInfo(String name, {String languageCode = 'en'});
}
