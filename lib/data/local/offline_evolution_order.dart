part of 'offline_evolution_queries.dart';

List<PokemonSpecies> orderEvolutionSpecies(List<PokemonSpecies> species) {
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
  final ordered = <PokemonSpecies>[];
  final visited = <int>{};
  void visit(PokemonSpecies item) {
    if (!visited.add(item.id)) return;
    ordered.add(item);
    for (final child in children[item.id] ?? const <PokemonSpecies>[]) {
      visit(child);
    }
  }

  for (final root in roots) {
    visit(root);
  }
  for (final item in species) {
    visit(item);
  }
  return ordered;
}
