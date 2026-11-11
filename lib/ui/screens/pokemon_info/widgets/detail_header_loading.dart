import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/components/pokemon_widgets.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_top_circle.dart';

class DetailHeaderLoading extends StatelessWidget {
  const DetailHeaderLoading({
    super.key,
    required this.initialPokemon,
    required this.onBack,
  });

  final PokemonItem initialPokemon;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          DetailTopCircle(types: initialPokemon.types),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.only(top: 52),
                child: _LoadingDetailHero(initialPokemon: initialPokemon),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDetailHero extends StatelessWidget {
  const _LoadingDetailHero({required this.initialPokemon});

  final PokemonItem initialPokemon;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 430).clamp(1.0, 1.45);
        final imageSize = 315.0 * scale;
        return Column(
          children: [
            Opacity(
              opacity: 1,
              child: Hero(
                tag: 'pokemon-image-${initialPokemon.name}',
                transitionOnUserGestures: true,
                child: Image.asset(
                  initialPokemon.imageUrl,
                  height: imageSize,
                  width: imageSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 12 * scale),
            LoadingState(size: 54 * scale),
          ],
        );
      },
    );
  }
}
