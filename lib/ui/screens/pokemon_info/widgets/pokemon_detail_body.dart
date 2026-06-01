import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_card.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_header.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_pages.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_tabs.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/swipeable_detail_page.dart';

class PokemonDetailBody extends StatelessWidget {
  const PokemonDetailBody({
    super.key,
    required this.pokemon,
    required this.selectedPage,
    required this.scrollController,
    required this.onBack,
    required this.onFavorite,
    required this.onPlayCry,
    required this.onPageSelected,
    required this.onEvolutionTap,
  });

  final PokemonInfo pokemon;
  final int selectedPage;
  final ScrollController scrollController;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final VoidCallback onPlayCry;
  final ValueChanged<int> onPageSelected;
  final ValueChanged<PokemonSpecies> onEvolutionTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            DetailHeader(
              pokemon: pokemon,
              onBack: onBack,
              onFavorite: onFavorite,
              onPlayCry: onPlayCry,
            ),
            PokemonDetailTypeBadges(types: pokemon.types),
            const SizedBox(height: 14),
            DetailTabs(
              selectedPage: selectedPage,
              onInfoClick: () => onPageSelected(0),
              onStatsClick: () => onPageSelected(1),
            ),
            DetailPageCard(
              child: SwipeableDetailPage(
                selectedPage: selectedPage,
                onPageSelected: onPageSelected,
                child: selectedPage == 0
                    ? PokemonInfoPage(
                        pokemon: pokemon,
                        onEvolutionTap: onEvolutionTap,
                      )
                    : PokemonStatsPage(pokemon: pokemon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
