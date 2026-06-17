import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/components/pokemon_widgets.dart';

class TypeResultsGrid extends StatelessWidget {
  const TypeResultsGrid({
    super.key,
    required this.future,
    required this.favorites,
    required this.onRetry,
    required this.onPokemonTap,
  });

  final Future<List<PokemonItem>> future;
  final FavoritesStore favorites;
  final VoidCallback onRetry;
  final ValueChanged<PokemonItem> onPokemonTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: favorites,
      builder: (context, _) {
        return FutureBuilder<List<PokemonItem>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingState();
            }
            if (snapshot.hasError) return ErrorState(onRetry: onRetry);
            return PokemonGrid(
              items: snapshot.data ?? [],
              favorites: favorites,
              onPokemonTap: onPokemonTap,
            );
          },
        );
      },
    );
  }
}
