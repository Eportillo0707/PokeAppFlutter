import 'package:flutter/material.dart';

import '../models/pokemon_models.dart';
import '../services/favorites_store.dart';
import '../services/pokeapi_client.dart';
import '../utils/pokemon_formatters.dart';
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

  @override
  void initState() {
    super.initState();
    future = widget.api.getPokemonByType(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(formatPokemonName(widget.type)),
        backgroundColor: pokemonTypeColor(widget.type),
      ),
      body: AnimatedBuilder(
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
                    () => future = widget.api.getPokemonByType(widget.type),
                  ),
                );
              }
              final items = snapshot.data ?? [];
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .92,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final pokemon = items[index]
                    ..isFavorite = widget.favorites.isFavorite(items[index].id);
                  return PokemonCard(
                    pokemon: pokemon,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PokemonDetailScreen(
                          api: widget.api,
                          favorites: widget.favorites,
                          initialPokemon: pokemon,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
