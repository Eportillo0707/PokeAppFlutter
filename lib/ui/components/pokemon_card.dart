import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';
import 'type_badge.dart';

part 'pokemon_card_parts.dart';
part 'pokemon_card_image.dart';

class PokemonCard extends StatelessWidget {
  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.onTap,
  });

  final PokemonItem pokemon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        color: const Color(0xFF202339),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: .12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: RepaintBoundary(
            child: Stack(
              children: [
                _PokedexNumber(id: pokemon.id),
                if (pokemon.isFavorite) const _FavoriteMark(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PokemonImage(pokemon: pokemon),
                    const SizedBox(height: 6),
                    _PokemonName(name: pokemon.name),
                    const SizedBox(height: 10),
                    _PokemonTypeRow(types: pokemon.types),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
