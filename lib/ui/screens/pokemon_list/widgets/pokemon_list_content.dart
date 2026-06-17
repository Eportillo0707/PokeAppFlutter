import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/components/pokemon_widgets.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/pokemon_list_controller.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/widgets/header_buttons.dart';

class PokemonListContent extends StatelessWidget {
  const PokemonListContent({
    super.key,
    required this.controller,
    required this.favorites,
    required this.onSearch,
    required this.onFilter,
    required this.onGenerationFilter,
    required this.onPokemonTap,
  });

  final PokemonListController controller;
  final FavoritesStore favorites;
  final VoidCallback onSearch;
  final VoidCallback onFilter;
  final VoidCallback onGenerationFilter;
  final ValueChanged<PokemonItem> onPokemonTap;

  @override
  Widget build(BuildContext context) {
    if (controller.loading) return const LoadingState();
    if (controller.hasError) {
      return ErrorState(onRetry: controller.loadFirstPage);
    }
    return Column(
      children: [
        const SizedBox(height: 10),
        HeaderButtons(
          onSearch: onSearch,
          onFilter: onFilter,
          onGenerationFilter: onGenerationFilter,
          hasGenerationFilter: controller.selectedGeneration != null,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.loadFirstPage,
            child: PokemonGrid(
              controller: controller.scrollController,
              items: controller.items,
              favorites: favorites,
              loadingMore: controller.loadingMore,
              onPokemonTap: onPokemonTap,
            ),
          ),
        ),
      ],
    );
  }
}
