import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';
import 'evolution_branch_item.dart';
import 'evolution_connector.dart';
import 'evolution_item.dart';
import 'evolution_method_label.dart';

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
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: .16)),
        ),
        child: Column(children: [
          LayoutBuilder(builder: (context, constraints) {
            const arrowWidth = 24.0;
            final itemWidth =
                (constraints.maxWidth - arrowWidth * (route.length - 1)) /
                    route.length;
            if (itemWidth < 60) {
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
            return Row(children: [
              for (var i = 0; i < route.length; i++) ...[
                if (i > 0)
                  EvolutionConnector(
                      target: route[i], width: arrowWidth, showDetails: false),
                EvolutionItem(
                    species: route[i],
                    width: itemWidth,
                    hero: heroFor(route[i]),
                    onTap: () => onSpeciesTap(route[i])),
              ],
            ]);
          }),
          for (final target in route.skip(1))
            if (target.evolutionMethod case final method?)
              Row(children: [
                Icon(Icons.arrow_forward,
                    size: 15, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 5),
                SizedBox(
                    width: 74,
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(formatPokemonName(target.name),
                            maxLines: 1,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)))),
                Expanded(
                    child: EvolutionMethodLabel(
                        method: method,
                        itemImageUrl: target.evolutionItemImageUrl)),
              ]),
        ]),
      );
}
