part of 'pokemon_list_controller.dart';

extension _PokemonListControllerFetch on PokemonListController {
  Future<List<PokemonItem>> _fetchPage() {
    final generation = selectedGeneration;
    return generation == null
        ? api.getPokemonList(
            limit: PokemonListController.pageSize,
            offset: offset,
          )
        : api.getPokemonByGeneration(
            generation,
            limit: PokemonListController.pageSize,
            offset: offset,
          );
  }
}
