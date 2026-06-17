import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/normalized_pokemon_artwork.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/pokemon_detail_hero_title.dart';

class PokemonDetailHero extends StatelessWidget {
  const PokemonDetailHero({
    super.key,
    required this.pokemon,
    required this.showShiny,
  });

  final PokemonInfo pokemon;
  final bool showShiny;

  @override
  Widget build(BuildContext context) {
    final imageUrl = showShiny
        ? pokemon.shinyImageUrl ?? pokemon.imageUrl
        : pokemon.imageUrl;
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 430).clamp(1.0, 1.45);
        final imageSize = 315.0 * scale;
        return Column(
          children: [
            _HeroImage(pokemon: pokemon, imageUrl: imageUrl, size: imageSize),
            PokemonDetailHeroTitle(pokemon: pokemon, titleSize: 50.0 * scale),
          ],
        );
      },
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({
    required this.pokemon,
    required this.imageUrl,
    required this.size,
  });

  final PokemonInfo pokemon;
  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'pokemon-image-${pokemon.name}',
      transitionOnUserGestures: true,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInCubic,
        child: SizedBox(
          key: ValueKey(imageUrl),
          height: size,
          width: size,
          child: NormalizedPokemonArtwork(
            normalUrl: pokemon.imageUrl,
            imageUrl: imageUrl,
            size: size,
          ),
        ),
      ),
    );
  }
}
