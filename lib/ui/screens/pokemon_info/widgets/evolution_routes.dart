import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';

List<List<PokemonSpecies>> evolutionRoutes(List<PokemonSpecies> species) {
  final byId = {for (final item in species) item.id: item};
  final children = <int, List<PokemonSpecies>>{};
  final roots = <PokemonSpecies>[];
  for (final item in species) {
    final parent = item.evolvesFromSpeciesId;
    if (parent == null || !byId.containsKey(parent)) {
      roots.add(item);
    } else {
      children.putIfAbsent(parent, () => []).add(item);
    }
  }
  final routes = <List<PokemonSpecies>>[];
  final covered = <int>{};
  void visit(PokemonSpecies item, List<PokemonSpecies> path) {
    if (path.any((entry) => entry.id == item.id)) return;
    final next = [...path, item];
    covered.add(item.id);
    final descendants = children[item.id] ?? const <PokemonSpecies>[];
    if (descendants.isEmpty) {
      routes.add(next);
      return;
    }
    for (final child in descendants) {
      visit(child, next);
    }
  }

  for (final root in roots) {
    visit(root, const []);
  }
  for (final item in species) {
    if (!covered.contains(item.id)) visit(item, const []);
  }
  return routes;
}
