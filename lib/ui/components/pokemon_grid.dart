import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'pokemon_card.dart';
import 'state_widgets.dart';

class PokemonGrid extends StatelessWidget {
  const PokemonGrid({
    super.key,
    required this.items,
    required this.favorites,
    required this.onPokemonTap,
    this.controller,
    this.loadingMore = false,
    this.padding = const EdgeInsets.all(8),
  });

  final List<PokemonItem> items;
  final FavoritesStore favorites;
  final ValueChanged<PokemonItem> onPokemonTap;
  final ScrollController? controller;
  final bool loadingMore;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverPadding(
          padding: padding,
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: .82,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final pokemon = items[index]
                  ..isFavorite = favorites.isFavorite(items[index].id);
                return PokemonCard(
                  pokemon: pokemon,
                  onTap: () => onPokemonTap(pokemon),
                );
              },
              childCount: items.length,
            ),
          ),
        ),
        if (loadingMore)
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 110,
              child: Center(child: LoadingState()),
            ),
          ),
      ],
    );
  }
}
