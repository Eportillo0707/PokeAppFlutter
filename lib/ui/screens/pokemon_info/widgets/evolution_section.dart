import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_card.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_branch_list.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_connector.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_item.dart';

class EvolutionSection extends StatelessWidget {
  const EvolutionSection(
      {super.key,
      required this.title,
      required this.species,
      required this.showArrows,
      required this.onSpeciesTap,
      required this.currentPokemonId,
      this.heroExcludedIds = const {}});

  final String title;
  final List<PokemonSpecies> species;
  final bool showArrows;
  final int currentPokemonId;
  final Set<int> heroExcludedIds;
  final ValueChanged<PokemonSpecies> onSpeciesTap;

  bool get _isShortLine =>
      species.length <= 3 &&
      (!showArrows ||
          List.generate(species.length - 1, (index) => index).every((index) =>
              species[index + 1].evolvesFromSpeciesId == species[index].id));

  @override
  Widget build(BuildContext context) => DetailPanel(
        title: title,
        child: LayoutBuilder(builder: (context, constraints) {
          final minWidth = showArrows && species.length == 3 ? 270 : 230;
          if (_isShortLine && constraints.maxWidth >= minWidth) {
            final arrowWidth = showArrows ? 44.0 : 0.0;
            final cardGap = showArrows ? 0.0 : 8.0;
            final itemWidth = (constraints.maxWidth -
                    (arrowWidth + cardGap) * (species.length - 1)) /
                species.length;
            return Row(children: [
              for (var i = 0; i < species.length; i++) ...[
                if (i > 0 && showArrows)
                  EvolutionConnector(target: species[i], width: arrowWidth),
                if (i > 0 && !showArrows) SizedBox(width: cardGap),
                EvolutionItem(
                  species: species[i],
                  width: itemWidth,
                  hero: species[i].id != currentPokemonId &&
                      !heroExcludedIds.contains(species[i].id),
                  onTap: () => onSpeciesTap(species[i]),
                ),
              ],
            ]);
          }
          return EvolutionBranchList(
            species: species,
            showArrows: showArrows,
            currentPokemonId: currentPokemonId,
            heroExcludedIds: heroExcludedIds,
            onSpeciesTap: onSpeciesTap,
          );
        }),
      );
}
