import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_artwork.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_type_icons.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';

class EvolutionItem extends StatelessWidget {
  const EvolutionItem(
      {super.key,
      required this.species,
      required this.onTap,
      this.width = 155,
      this.height,
      this.hero = true,
      this.showMethod = false});

  final PokemonSpecies species;
  final VoidCallback onTap;
  final double width;
  final double? height;
  final bool hero;
  final bool showMethod;

  @override
  Widget build(BuildContext context) {
    final imageSize = (width - 14).clamp(48.0, 92.0);
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              EvolutionArtwork(species: species, size: imageSize, hero: hero),
              const SizedBox(height: 5),
              Text('#${species.id.toString().padLeft(4, '0')}',
                  style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 2),
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(formatPokemonName(species.name),
                        maxLines: 1,
                        softWrap: false,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700))),
              ),
              if (showMethod && species.evolutionMethod != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: .17),
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(species.evolutionMethod!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 9.5, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              EvolutionTypeIcons(types: species.types),
            ]),
          ),
        ),
      ),
    );
  }
}
