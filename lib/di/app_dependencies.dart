import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/data/remote/mappers/pokemon_mapper.dart';
import 'package:pokeapp_flutter/data/remote/pokeapi_http_client.dart';
import 'package:pokeapp_flutter/data/remote/pokemon_remote_data_source.dart';
import 'package:pokeapp_flutter/data/repositories/pokemon_repository_impl.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';

class AppDependencies {
  AppDependencies() {
    final httpClient = PokeApiHttpClient();
    final remoteDataSource = PokemonRemoteDataSource(client: httpClient);
    pokemonRepository = PokemonRepositoryImpl(
      remoteDataSource: remoteDataSource,
      mapper: PokemonMapper(),
    );
    favoritesStore = FavoritesStore();
  }

  late final PokemonRepository pokemonRepository;
  late final FavoritesStore favoritesStore;
}
