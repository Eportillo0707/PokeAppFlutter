import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'package:pokeapp_flutter/ui/components/pokemon_widgets.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/pokemon_detail_screen.dart';

class TypeScreen extends StatefulWidget {
  const TypeScreen({
    super.key,
    required this.api,
    required this.favorites,
    required this.type,
  });

  final PokemonRepository api;
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
                      return PokemonGrid(
                        items: items,
                        favorites: widget.favorites,
                        onPokemonTap: (pokemon) => Navigator.of(context).push(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
