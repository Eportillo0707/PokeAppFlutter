import 'package:flutter/material.dart';
import 'evolution_hero_scope.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_method_label.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';

class EvolutionBranchItem extends StatelessWidget {
  const EvolutionBranchItem(
      {super.key,
      required this.species,
      required this.depth,
      required this.showArrow,
      required this.hero,
      required this.onTap});

  final PokemonSpecies species;
  final int depth;
  final bool showArrow;
  final bool hero;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final artwork = Image.asset(species.imageUrl,
        width: 76, height: 76, fit: BoxFit.contain);
    return Padding(
      padding: EdgeInsets.only(left: (depth * 14).clamp(0, 42).toDouble()),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            if (showArrow) const Icon(Icons.subdirectory_arrow_right, size: 24),
            hero && EvolutionHeroScope.enabled(context, species.name)
                ? Hero(
                    tag: 'pokemon-image-${species.name}',
                    transitionOnUserGestures: true,
                    child: artwork)
                : artwork,
            const SizedBox(width: 8),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(formatPokemonName(species.name),
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800))),
                ),
                if (species.evolutionMethod != null)
                  EvolutionMethodLabel(
                    method: species.evolutionMethod!,
                    itemImageUrl: species.evolutionItemImageUrl,
                  ),
              ],
            )),
          ]),
        ),
      ),
    );
  }
}
