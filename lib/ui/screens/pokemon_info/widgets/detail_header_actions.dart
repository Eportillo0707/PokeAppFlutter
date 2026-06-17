import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_round_action_button.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';

class DetailHeaderActions extends StatelessWidget {
  const DetailHeaderActions({
    super.key,
    required this.pokemon,
    required this.showShiny,
    required this.onFavorite,
    required this.onPlayCry,
    required this.onShinyToggle,
  });

  final PokemonInfo pokemon;
  final bool showShiny;
  final VoidCallback onFavorite;
  final VoidCallback onPlayCry;
  final VoidCallback? onShinyToggle;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          children: [
            IconButton(
              onPressed: onFavorite,
              icon: Icon(
                pokemon.isFavorite ? Icons.star : Icons.star_border,
                size: 34,
                color:
                    pokemon.isFavorite ? const Color(0xFFFFD54F) : Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            DetailRoundActionButton(
              enabled: pokemon.cryUrl != null && pokemon.cryUrl!.isNotEmpty,
              color: pokemonTypeColor(pokemon.types.firstOrNull),
              icon: Icons.volume_up,
              iconColor: Colors.white,
              onTap: onPlayCry,
            ),
            const SizedBox(height: 8),
            DetailRoundActionButton(
              enabled: pokemon.shinyImageUrl != null,
              color:
                  showShiny ? const Color(0xFFFFD54F) : const Color(0xFF232B4C),
              icon: Icons.auto_awesome,
              iconColor: showShiny ? const Color(0xFF121422) : Colors.white,
              onTap: onShinyToggle,
            ),
          ],
        ),
      ),
    );
  }
}
