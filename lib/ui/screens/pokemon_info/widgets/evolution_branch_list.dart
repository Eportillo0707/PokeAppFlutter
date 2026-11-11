import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_branch_item.dart';

class EvolutionBranchList extends StatelessWidget {
  const EvolutionBranchList(
      {super.key,
      required this.species,
      required this.showArrows,
      required this.currentPokemonId,
      required this.onSpeciesTap,
      this.heroExcludedIds = const {}});

  final List<PokemonSpecies> species;
  final bool showArrows;
  final int currentPokemonId;
  final Set<int> heroExcludedIds;
  final ValueChanged<PokemonSpecies> onSpeciesTap;

  @override
  Widget build(BuildContext context) {
    final depths = <int, int>{};
    final ids = species.map((item) => item.id).toSet();
    return Column(
        children: species.map((item) {
      final parent = item.evolvesFromSpeciesId;
      final hasParent = showArrows && parent != null && ids.contains(parent);
      final depth = hasParent ? (depths[parent] ?? 0) + 1 : 0;
      depths[item.id] = depth;
      return EvolutionBranchItem(
        species: item,
        depth: depth,
        showArrow: hasParent,
        hero: item.id != currentPokemonId && !heroExcludedIds.contains(item.id),
        onTap: () => onSpeciesTap(item),
      );
    }).toList());
  }
}
