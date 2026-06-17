import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/pokemon_detail_screen.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/widgets/type_results_grid.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/widgets/type_screen_header.dart';

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
            TypeScreenHeader(type: widget.type),
            Expanded(
              child: TypeResultsGrid(
                future: future,
                favorites: widget.favorites,
                onRetry: _reload,
                onPokemonTap: _openDetail,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _reload() {
    setState(() => future = widget.api.getPokemonByType(widget.type));
  }

  void _openDetail(PokemonItem pokemon) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PokemonDetailScreen(
          api: widget.api,
          favorites: widget.favorites,
          initialPokemon: pokemon,
        ),
      ),
    );
  }
}
