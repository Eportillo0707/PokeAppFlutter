import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'detail_card.dart';
import 'evolution_branch_item.dart';
import 'evolution_fork.dart';
import 'evolution_item.dart';

class EvolutionManyBranchesSection extends StatelessWidget {
  const EvolutionManyBranchesSection(
      {super.key,
      required this.title,
      required this.fork,
      required this.currentPokemonId,
      required this.heroExcludedIds,
      required this.onSpeciesTap});

  final String title;
  final EvolutionFork fork;
  final int currentPokemonId;
  final Set<int> heroExcludedIds;
  final ValueChanged<PokemonSpecies> onSpeciesTap;

  @override
  Widget build(BuildContext context) => DetailPanel(
        title: title,
        child: LayoutBuilder(builder: (context, constraints) {
          final width = (constraints.maxWidth - 8) / 2;
          bool hero(PokemonSpecies item) =>
              item.id != currentPokemonId && !heroExcludedIds.contains(item.id);
          return Column(children: [
            for (var i = 0; i < fork.shared.length; i++)
              EvolutionBranchItem(
                  species: fork.shared[i],
                  depth: i,
                  showArrow: i > 0,
                  hero: hero(fork.shared[i]),
                  onTap: () => onSpeciesTap(fork.shared[i])),
            Icon(Icons.arrow_downward,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final item in fork.branches)
                EvolutionItem(
                    species: item,
                    width: width,
                    height: 210,
                    showMethod: true,
                    hero: hero(item),
                    onTap: () => onSpeciesTap(item)),
            ]),
          ]);
        }),
      );
}
