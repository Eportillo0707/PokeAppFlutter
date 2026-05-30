import 'package:flutter/material.dart';

import '../services/favorites_store.dart';
import '../services/pokeapi_client.dart';
import '../widgets/pokemon_widgets.dart';
import 'pokemon_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
    required this.api,
    required this.favorites,
  });

  final PokeApiClient api;
  final FavoritesStore favorites;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String? selectedHeroName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121422),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const Align(
                    child: Text(
                      'Favorites',
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
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
                animation: widget.favorites,
                builder: (context, _) {
                  final items = widget.favorites.items;
                  if (items.isEmpty) {
                    return const Center(child: Text('Aun no hay favoritos'));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: .82,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final pokemon = items[index]..isFavorite = true;
                      return PokemonCard(
                        pokemon: pokemon,
                        enableHero: selectedHeroName == pokemon.name,
                        onTap: () {
                          setState(() => selectedHeroName = pokemon.name);
                          final navigator = Navigator.of(context);
                          Future<void>.delayed(
                            const Duration(milliseconds: 40),
                            () async {
                              if (!mounted) return;
                              await navigator.push(
                                MaterialPageRoute(
                                  builder: (_) => PokemonDetailScreen(
                                    api: widget.api,
                                    favorites: widget.favorites,
                                    initialPokemon: pokemon,
                                  ),
                                ),
                              );
                              if (mounted) {
                                setState(() => selectedHeroName = null);
                              }
                            },
                          );
                        },
                      );
                    },
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
