import 'package:flutter/material.dart';

import '../models/pokemon_models.dart';
import '../services/favorites_store.dart';
import '../services/pokeapi_client.dart';
import '../widgets/pokemon_widgets.dart';
import 'pokemon_detail_screen.dart';

class TypeScreen extends StatefulWidget {
  const TypeScreen({
    super.key,
    required this.api,
    required this.favorites,
    required this.type,
  });

  final PokeApiClient api;
  final FavoritesStore favorites;
  final String type;

  @override
  State<TypeScreen> createState() => _TypeScreenState();
}

class _TypeScreenState extends State<TypeScreen> {
  late Future<List<PokemonItem>> future;
  String? selectedHeroName;

  @override
  void initState() {
    super.initState();
    future = widget.api.getPokemonByType(widget.type);
  }

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
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  Align(
                    child: TypeBadgeImage(type: widget.type, width: 120),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: widget.favorites,
                builder: (context, _) {
                  return FutureBuilder<List<PokemonItem>>(
                    future: future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const LoadingState();
                      }
                      if (snapshot.hasError) {
                        return ErrorState(
                          onRetry: () => setState(
                            () => future =
                                widget.api.getPokemonByType(widget.type),
                          ),
                        );
                      }
                      final items = snapshot.data ?? [];
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
                          final pokemon = items[index]
                            ..isFavorite =
                                widget.favorites.isFavorite(items[index].id);
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
