import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/animated_action.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_round_action_button.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/shiny_sparkle_burst.dart';

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
            AnimatedAction(
              onTap: onFavorite,
              child: IconButton(
                onPressed: null,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  child: Icon(
                    pokemon.isFavorite ? Icons.star : Icons.star_border,
                    key: ValueKey(pokemon.isFavorite),
                    size: 34,
                    color: pokemon.isFavorite
                        ? const Color(0xFFFFD54F)
                        : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedAction(
              onTap: pokemon.cryUrl != null && pokemon.cryUrl!.isNotEmpty
                  ? onPlayCry
                  : null,
              child: DetailRoundActionButton(
                enabled: pokemon.cryUrl != null && pokemon.cryUrl!.isNotEmpty,
                color: const Color(0xFF232B4C),
                icon: Icons.volume_up,
                iconColor: Colors.white,
                onTap: null,
              ),
            ),
            const SizedBox(height: 8),
            ShinySparkleBurst(
              active: showShiny,
              child: DetailRoundActionButton(
                enabled: pokemon.shinyImageUrl != null,
                color: showShiny
                    ? const Color(0xFFFFD54F)
                    : const Color(0xFF232B4C),
                icon: Icons.auto_awesome,
                iconColor: showShiny ? const Color(0xFF121422) : Colors.white,
                onTap: onShinyToggle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
