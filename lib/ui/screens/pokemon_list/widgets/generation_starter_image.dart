import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_generation.dart';

class GenerationStarterImage extends StatelessWidget {
  const GenerationStarterImage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Image.network(
        officialPokemonArtworkUrl(id),
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
