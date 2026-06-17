import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'package:pokeapp_flutter/ui/components/pokemon_widgets.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/pokemon_detail_screen.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/pokemon_list_controller.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/type_screen.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/widgets/generation_filter_sheet.dart';
import 'package:pokeapp_flutter/ui/screens/search_pokemon/search_screen.dart';

class PokemonListRoutes {
  const PokemonListRoutes({
    required this.context,
    required this.api,
    required this.favorites,
    required this.controller,
  });

  final BuildContext context;
  final PokemonRepository api;
  final FavoritesStore favorites;
  final PokemonListController controller;

  void openSearch() => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SearchScreen(api: api, favorites: favorites),
        ),
      );

  void openDetail(PokemonItem pokemon) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PokemonDetailScreen(
            api: api,
            favorites: favorites,
            initialPokemon: pokemon,
          ),
        ),
      );

  void showTypePicker() => showModalBottomSheet<void>(
        context: context,
        backgroundColor: const Color(0xFF232B4C),
        builder: (_) => TypePickerSheet(onSelected: openType),
      );

  void openType(String type) {
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TypeScreen(api: api, favorites: favorites, type: type),
      ),
    );
  }

  Future<void> showGenerationPicker() async {
    await controller.ensureGenerationImagesReady(context);
    if (!context.mounted) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF121422),
      isScrollControlled: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: .72,
        child: GenerationFilterSheet(
          selectedGeneration: controller.selectedGeneration,
          onSelected: (generation) {
            Navigator.pop(context);
            controller.selectGeneration(generation);
          },
        ),
      ),
    );
  }
}
