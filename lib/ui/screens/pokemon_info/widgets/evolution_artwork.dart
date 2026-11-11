import 'package:flutter/material.dart';
import 'evolution_hero_scope.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';

class EvolutionArtwork extends StatelessWidget {
  const EvolutionArtwork(
      {super.key,
      required this.species,
      required this.size,
      required this.hero});

  final PokemonSpecies species;
  final double size;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(species.imageUrl,
        width: size, height: size, fit: BoxFit.contain);
    final artwork = DecoratedBox(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .13)),
      child: image,
    );
    return hero && EvolutionHeroScope.enabled(context, species.name)
        ? Hero(
            tag: 'pokemon-image-${species.name}',
            transitionOnUserGestures: true,
            child: artwork)
        : artwork;
  }
}
