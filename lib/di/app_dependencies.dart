import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/data/remote/pokeapi_client.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';

class AppDependencies {
  AppDependencies()
      : pokemonRepository = PokeApiClient(),
        favoritesStore = FavoritesStore();

  final PokemonRepository pokemonRepository;
  final FavoritesStore favoritesStore;
}
