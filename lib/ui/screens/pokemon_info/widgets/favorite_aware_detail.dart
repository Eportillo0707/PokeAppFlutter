import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/pokemon_detail_body.dart';

class FavoriteAwareDetail extends StatelessWidget {
  const FavoriteAwareDetail({
    super.key,
    required this.pokemon,
    required this.favorites,
    required this.selectedPage,
    required this.showShiny,
    required this.scrollController,
    required this.onBack,
    required this.onFavorite,
    required this.onPlayCry,
    required this.onShinyToggle,
    required this.onPageSelected,
    required this.onEvolutionTap,
  });

  final PokemonInfo pokemon;
  final FavoritesStore favorites;
  final int selectedPage;
  final bool showShiny;
  final ScrollController scrollController;
  final VoidCallback onBack;
  final ValueChanged<PokemonInfo> onFavorite;
  final ValueChanged<PokemonInfo> onPlayCry;
  final VoidCallback onShinyToggle;
  final ValueChanged<int> onPageSelected;
  final ValueChanged<PokemonSpecies> onEvolutionTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: favorites,
      builder: (context, _) {
        pokemon.isFavorite = favorites.isFavorite(pokemon.id);
        return PokemonDetailBody(
          pokemon: pokemon,
          selectedPage: selectedPage,
          showShiny: showShiny && pokemon.shinyImageUrl != null,
          scrollController: scrollController,
          onBack: onBack,
          onFavorite: () => onFavorite(pokemon),
          onPlayCry: () => onPlayCry(pokemon),
          onShinyToggle: pokemon.shinyImageUrl == null ? null : onShinyToggle,
          onPageSelected: onPageSelected,
          onEvolutionTap: onEvolutionTap,
        );
      },
    );
  }
}
