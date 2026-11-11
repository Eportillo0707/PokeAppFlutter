import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_card.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/mega_evolution_group.dart';

class MegaEvolutionSection extends StatelessWidget {
  const MegaEvolutionSection(
      {super.key,
      required this.title,
      required this.normal,
      required this.mega,
      required this.currentPokemonId,
      required this.onSpeciesTap});

  final String title;
  final List<PokemonSpecies> normal;
  final List<PokemonSpecies> mega;
  final int currentPokemonId;
  final ValueChanged<PokemonSpecies> onSpeciesTap;

  @override
  Widget build(BuildContext context) {
    final parents = {for (final item in normal) item.id: item};
    final groups = <int, List<PokemonSpecies>>{};
    for (final form in mega) {
      groups.putIfAbsent(form.evolvesFromSpeciesId ?? -1, () => []).add(form);
    }
    return DetailPanel(
      title: title,
      child: Column(children: [
        for (final entry in groups.entries)
          MegaEvolutionGroup(
            parent: parents[entry.key],
            forms: entry.value,
            currentPokemonId: currentPokemonId,
            onSpeciesTap: onSpeciesTap,
          ),
      ]),
    );
  }
}
