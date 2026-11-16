import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'detail_card.dart';
import 'evolution_branch_list.dart';
import 'evolution_connector.dart';
import 'evolution_fork.dart';
import 'evolution_item.dart';
import 'evolution_many_branches_section.dart';

class EvolutionForkSection extends StatelessWidget {
  const EvolutionForkSection(
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
  Widget build(BuildContext context) => fork.branches.length > 3
      ? EvolutionManyBranchesSection(
          title: title,
          fork: fork,
          currentPokemonId: currentPokemonId,
          heroExcludedIds: heroExcludedIds,
          onSpeciesTap: onSpeciesTap)
      : DetailPanel(
          title: title,
          child: LayoutBuilder(builder: (context, constraints) {
            const arrowWidth = 48.0;
            const stageHeight = 180.0;
            const gap = 8.0;
            final columns = fork.shared.length + 1;
            final width =
                (constraints.maxWidth - arrowWidth * (columns - 1)) / columns;
            if (width < 62) {
              return EvolutionBranchList(
                  species: [...fork.shared, ...fork.branches],
                  showArrows: true,
                  currentPokemonId: currentPokemonId,
                  heroExcludedIds: heroExcludedIds,
                  onSpeciesTap: onSpeciesTap);
            }
            final totalHeight = fork.branches.length * stageHeight +
                (fork.branches.length - 1) * gap;
            bool hero(PokemonSpecies item) =>
                item.id != currentPokemonId &&
                !heroExcludedIds.contains(item.id);
            return Row(children: [
              for (var i = 0; i < fork.shared.length; i++) ...[
                if (i > 0)
                  EvolutionConnector(
                      target: fork.shared[i],
                      width: arrowWidth,
                      maxMethodLines: 5),
                EvolutionItem(
                    species: fork.shared[i],
                    width: width,
                    height: totalHeight,
                    centerContent: true,
                    hero: hero(fork.shared[i]),
                    onTap: () => onSpeciesTap(fork.shared[i])),
              ],
              SizedBox(
                  width: arrowWidth,
                  child: Column(children: [
                    for (var i = 0; i < fork.branches.length; i++) ...[
                      if (i > 0) const SizedBox(height: gap),
                      SizedBox(
                          height: stageHeight,
                          child: Center(
                              child: EvolutionConnector(
                                  target: fork.branches[i],
                                  width: arrowWidth,
                                  maxMethodLines: 5))),
                    ],
                  ])),
              Column(children: [
                for (var i = 0; i < fork.branches.length; i++) ...[
                  if (i > 0) const SizedBox(height: gap),
                  EvolutionItem(
                      species: fork.branches[i],
                      width: width,
                      height: stageHeight,
                      centerContent: true,
                      hero: hero(fork.branches[i]),
                      onTap: () => onSpeciesTap(fork.branches[i])),
                ],
              ]),
            ]);
          }),
        );
}
