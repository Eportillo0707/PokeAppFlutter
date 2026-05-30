import 'package:flutter/material.dart';

import '../services/favorites_store.dart';
import '../services/pokeapi_client.dart';
import '../widgets/pokemon_widgets.dart';
import 'pokemon_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.api,
    required this.favorites,
  });

  final PokeApiClient api;
  final FavoritesStore favorites;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121422),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(
              height: 60,
              child: Stack(
                children: [
                  Align(
                    child: Text(
                      'Favorites',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: favorites,
                builder: (context, _) {
                  final items = favorites.items;
                  if (items.isEmpty) {
                    return const Center(child: Text('Aun no hay favoritos'));
                  }
                  return PokemonGrid(
                    items: items,
                    favorites: favorites,
                    onPokemonTap: (pokemon) => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PokemonDetailScreen(
                          api: api,
                          favorites: favorites,
                          initialPokemon: pokemon,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
