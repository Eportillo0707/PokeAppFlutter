import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_header_actions.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_top_circle.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/pokemon_detail_hero.dart';

export 'detail_header_loading.dart';
export 'detail_top_circle.dart';
export 'pokemon_detail_type_badges.dart';

class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.pokemon,
    required this.showShiny,
    required this.onBack,
    required this.onFavorite,
    required this.onPlayCry,
    required this.onShinyToggle,
  });

  final PokemonInfo pokemon;
  final bool showShiny;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final VoidCallback onPlayCry;
  final VoidCallback? onShinyToggle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        DetailTopCircle(types: pokemon.types),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SizedBox(
              width: double.infinity,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  _BackButton(onPressed: onBack),
                  DetailHeaderActions(
                    pokemon: pokemon,
                    showShiny: showShiny,
                    onFavorite: onFavorite,
                    onPlayCry: onPlayCry,
                    onShinyToggle: onShinyToggle,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 52),
                    child: PokemonDetailHero(
                      pokemon: pokemon,
                      showShiny: showShiny,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }
}
