import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/pokemon_detail_screen.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/type_screen.dart';
import 'package:pokeapp_flutter/ui/screens/search_pokemon/search_controller.dart';
import 'package:pokeapp_flutter/ui/screens/search_pokemon/widgets/search_content.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.api,
    required this.favorites,
  });

  final PokemonRepository api;
  final FavoritesStore favorites;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final PokemonSearchController controller;

  @override
  void initState() {
    super.initState();
    controller = PokemonSearchController(api: widget.api)..init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.requestFocus();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121422),
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.favorites, controller]),
          builder: (context, _) => SearchContent(
            controller: controller,
            favorites: widget.favorites,
            onBack: () => Navigator.of(context).pop(),
            onTypeSelected: _openType,
            onPokemonTap: _openDetail,
          ),
        ),
      ),
    );
  }

  void _openType(String type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TypeScreen(
          api: widget.api,
          favorites: widget.favorites,
          type: type,
        ),
      ),
    );
  }
}
