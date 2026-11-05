import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_move.dart';

import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/components/pokemon_widgets.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_header.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/favorite_aware_detail.dart';

class PokemonDetailLoader extends StatelessWidget {
  const PokemonDetailLoader({
    super.key,
    required this.future,
    required this.initialPokemon,
    required this.favorites,
    required this.selectedPage,
    required this.showShiny,
    required this.scrollController,
    required this.onRetry,
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

  final Future<PokemonInfo> future;
  final PokemonItem initialPokemon;
  final FavoritesStore favorites;
  final int selectedPage;
  final bool showShiny;
  final ScrollController scrollController;
  final VoidCallback onRetry;
  final VoidCallback onBack;
  final ValueChanged<PokemonInfo> onFavorite;
  final ValueChanged<PokemonInfo> onPlayCry;
  final VoidCallback onShinyToggle;
  final ValueChanged<int> onPageSelected;
  final ValueChanged<PokemonSpecies> onEvolutionTap;
  final MoveMachineLoader? loadMachines;
  final MoveDescriptionLoader? loadDescription;
  final MoveBattleLoader? loadBattleInfo;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PokemonInfo>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return DetailHeaderLoading(
              initialPokemon: initialPokemon, onBack: onBack);
        }
        if (snapshot.hasError) return ErrorState(onRetry: onRetry);
        return FavoriteAwareDetail(
          pokemon: snapshot.data!,
          favorites: favorites,
          selectedPage: selectedPage,
          showShiny: showShiny,
          scrollController: scrollController,
          onBack: onBack,
          onFavorite: onFavorite,
          onPlayCry: onPlayCry,
          onShinyToggle: onShinyToggle,
          onPageSelected: onPageSelected,
          onEvolutionTap: onEvolutionTap,
          loadMachines: loadMachines,
          loadDescription: loadDescription,
          loadBattleInfo: loadBattleInfo,
        );
      },
    );
  }
}
