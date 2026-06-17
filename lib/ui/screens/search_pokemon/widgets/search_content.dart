import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/components/pokemon_widgets.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/screens/search_pokemon/search_controller.dart';
import 'package:pokeapp_flutter/ui/screens/search_pokemon/widgets/search_top_bar.dart';

class SearchContent extends StatelessWidget {
  const SearchContent({
    super.key,
    required this.controller,
    required this.favorites,
    required this.onBack,
    required this.onTypeSelected,
    required this.onPokemonTap,
  });

  final PokemonSearchController controller;
  final FavoritesStore favorites;
  final VoidCallback onBack;
  final ValueChanged<String> onTypeSelected;
  final ValueChanged<PokemonItem> onPokemonTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        SearchTopBar(
          controller: controller.textController,
          focusNode: controller.focusNode,
          onBack: onBack,
          onTypeSelected: onTypeSelected,
        ),
        const SizedBox(height: 10),
        Expanded(
            child: _SearchResults(
                controller: controller,
                favorites: favorites,
                onPokemonTap: onPokemonTap)),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.controller,
    required this.favorites,
    required this.onPokemonTap,
  });

  final PokemonSearchController controller;
  final FavoritesStore favorites;
  final ValueChanged<PokemonItem> onPokemonTap;

  @override
  Widget build(BuildContext context) {
    if (controller.loading) return const LoadingState();
    if (controller.searched && controller.results.isEmpty) {
      return Center(child: Text(context.l10n.noResults));
    }
    return PokemonGrid(
      items: controller.results,
      favorites: favorites,
      onPokemonTap: onPokemonTap,
    );
  }
}
