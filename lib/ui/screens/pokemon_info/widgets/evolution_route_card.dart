import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'evolution_branch_item.dart';
import 'evolution_connector.dart';
import 'evolution_item.dart';

class EvolutionRouteCard extends StatelessWidget {
  const EvolutionRouteCard(
      {super.key,
      required this.route,
      required this.heroFor,
      required this.onSpeciesTap});

  final List<PokemonSpecies> route;
  final bool Function(PokemonSpecies) heroFor;
  final ValueChanged<PokemonSpecies> onSpeciesTap;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        color: Theme.of(context).colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: .16)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(builder: (context, constraints) {
            final minWidth = route.length == 3 ? 270 : 230;
            if (constraints.maxWidth < minWidth) {
              return Column(children: [
                for (var i = 0; i < route.length; i++)
                  EvolutionBranchItem(
                      species: route[i],
                      depth: i,
                      showArrow: i > 0,
                      hero: heroFor(route[i]),
                      onTap: () => onSpeciesTap(route[i])),
              ]);
            }
            const arrowWidth = 44.0;
            final itemWidth =
                (constraints.maxWidth - arrowWidth * (route.length - 1)) /
                    route.length;
            return Row(children: [
              for (var i = 0; i < route.length; i++) ...[
                if (i > 0)
                  EvolutionConnector(target: route[i], width: arrowWidth),
                EvolutionItem(
                    species: route[i],
                    width: itemWidth,
                    hero: heroFor(route[i]),
                    onTap: () => onSpeciesTap(route[i])),
              ],
            ]);
          }),
        ),
      );
}
