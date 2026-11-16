import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';

class EvolutionFork {
  const EvolutionFork(this.shared, this.branches);
  final List<PokemonSpecies> shared;
  final List<PokemonSpecies> branches;

  static EvolutionFork? fromRoutes(List<List<PokemonSpecies>> routes) {
    if (routes.length < 2) return null;
    final first = routes.first;
    var sharedLength = 0;
    while (sharedLength < first.length &&
        routes.every((route) =>
            route.length > sharedLength &&
            route[sharedLength].id == first[sharedLength].id)) {
      sharedLength++;
    }
    if (sharedLength == 0 ||
        routes.any((route) => route.length != sharedLength + 1)) {
      return null;
    }
    return EvolutionFork(first.take(sharedLength).toList(),
        routes.map((route) => route.last).toList());
  }
}
