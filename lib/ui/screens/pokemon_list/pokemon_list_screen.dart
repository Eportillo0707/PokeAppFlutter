import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/pokemon_list_controller.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/pokemon_list_routes.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/widgets/pokemon_list_content.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/widgets/scroll_top_button.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen(
      {super.key, required this.api, required this.favorites});

  final PokemonRepository api;
  final FavoritesStore favorites;

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  late final PokemonListController controller;

  @override
  void initState() {
    super.initState();
    controller = PokemonListController(api: widget.api)..init(context);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routes = PokemonListRoutes(
      context: context,
      api: widget.api,
      favorites: widget.favorites,
      controller: controller,
    );
    return Scaffold(
      backgroundColor: const Color(0xFF121422),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: controller.showScrollTop,
        builder: (context, visible, child) =>
            visible ? child! : const SizedBox(),
        child: ScrollTopButton(controller: controller.scrollController),
      ),
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.favorites, controller]),
          builder: (context, _) => PokemonListContent(
            controller: controller,
            favorites: widget.favorites,
            onSearch: routes.openSearch,
            onFilter: routes.showTypePicker,
            onGenerationFilter: routes.showGenerationPicker,
            onPokemonTap: routes.openDetail,
          ),
        ),
      ),
    );
  }
}
