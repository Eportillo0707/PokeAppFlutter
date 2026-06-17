import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';

class PokemonDetailHeroTitle extends StatelessWidget {
  const PokemonDetailHeroTitle({
    super.key,
    required this.pokemon,
    required this.titleSize,
  });

  final PokemonInfo pokemon;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            '#${pokemon.id.toString().padLeft(3, '0')}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .68),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatPokemonName(pokemon.name),
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
