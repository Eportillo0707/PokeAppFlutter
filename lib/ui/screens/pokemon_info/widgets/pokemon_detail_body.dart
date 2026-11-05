import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_move.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_card.dart';
import 'detail_moves.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_header.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_pages.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_tabs.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/swipeable_detail_page.dart';

class PokemonDetailBody extends StatelessWidget {
  const PokemonDetailBody({
    super.key,
    required this.pokemon,
    required this.selectedPage,
    required this.showShiny,
    required this.scrollController,
    required this.onBack,
    required this.onFavorite,
    required this.onPlayCry,
    required this.onShinyToggle,
    required this.onPageSelected,
    required this.onEvolutionTap,
    this.loadMachines,
    this.loadDescription,
    this.loadBattleInfo,
  });

  final PokemonInfo pokemon;
  final int selectedPage;
  final bool showShiny;
  final ScrollController scrollController;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final VoidCallback onPlayCry;
  final VoidCallback? onShinyToggle;
  final ValueChanged<int> onPageSelected;
  final ValueChanged<PokemonSpecies> onEvolutionTap;
  final MoveMachineLoader? loadMachines;
  final MoveDescriptionLoader? loadDescription;
  final MoveBattleLoader? loadBattleInfo;

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
              showShiny: showShiny,
              onBack: onBack,
              onFavorite: onFavorite,
              onPlayCry: onPlayCry,
              onShinyToggle: onShinyToggle,
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  children: [
                    PokemonDetailTypeBadges(types: pokemon.types),
                    const SizedBox(height: 14),
                    DetailTabs(
                      selectedPage: selectedPage,
                      onInfoClick: () => onPageSelected(0),
                      onStatsClick: () => onPageSelected(1),
                      onMovesClick: () => onPageSelected(2),
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
                            : selectedPage == 1
                                ? PokemonStatsPage(pokemon: pokemon)
                                : PokemonMovesPage(
                                    key: ValueKey('moves-${pokemon.id}'),
                                    moves: pokemon.moves,
                                    pokemonId: pokemon.id,
                                    loadMachines: loadMachines,
                                    loadDescription: loadDescription,
                                    loadBattleInfo: loadBattleInfo,
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
