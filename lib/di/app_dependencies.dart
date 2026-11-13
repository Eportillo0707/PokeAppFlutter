import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/data/local/offline_catalog_database.dart';
import 'package:pokeapp_flutter/data/local/offline_pokemon_repository.dart';
import 'package:pokeapp_flutter/data/updates/catalog_media_resolver.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';

class AppDependencies {
  AppDependencies._(
      this.pokemonRepository, this.favoritesStore, this.mediaResolver);

  static Future<AppDependencies> create() async {
    final catalog = await OfflineCatalogDatabase.open();
    return AppDependencies._(OfflinePokemonRepository(catalog),
        FavoritesStore(), catalog.mediaResolver);
  }

  late final PokemonRepository pokemonRepository;
  late final FavoritesStore favoritesStore;
  final CatalogMediaResolver mediaResolver;
}
