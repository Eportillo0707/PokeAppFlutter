import 'package:pokeapp_flutter/data/remote/pokeapi_http_client.dart';

class PokemonRemoteDataSource {
  const PokemonRemoteDataSource({required PokeApiHttpClient client})
      : _client = client;

  final PokeApiHttpClient _client;

  Future<Map<String, dynamic>> getPokemonList({
    required int limit,
    required int offset,
  }) {
    return _client.getJson('/pokemon?limit=$limit&offset=$offset');
  }

  Future<Map<String, dynamic>> getAllPokemonNames() {
    return _client.getJson('/pokemon?limit=1302&offset=0');
  }

  Future<Map<String, dynamic>> getPokemon(String name) {
    return _client.getJson('/pokemon/${name.toLowerCase()}');
  }

  Future<Map<String, dynamic>> getPokemonSpecies(String name) {
    return _client.getJson('/pokemon-species/$name');
  }

  Future<Map<String, dynamic>> getPokemonByType(String type) {
    return _client.getJson('/type/${type.toLowerCase()}');
  }

  Future<Map<String, dynamic>> getAbility(String name) {
    return _client.getJson('/ability/$name');
  }

  Future<Map<String, dynamic>> getAbsoluteJson(String url) {
    return _client.getAbsoluteJson(url);
  }
}
