import 'package:flutter/material.dart';
import 'widgets/evolution_hero_scope.dart';

import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/pokemon_detail_controller.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/pokemon_detail_routes.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/pokemon_detail_loader.dart';

part 'pokemon_detail_screen_actions.dart';

class PokemonDetailScreen extends StatefulWidget {
  const PokemonDetailScreen({
    super.key,
    required this.api,
    required this.favorites,
    required this.initialPokemon,
    this.preloadedInfo,
    this.preloadedLanguageCode,
  });

  final PokemonRepository api;
  final FavoritesStore favorites;
  final PokemonItem initialPokemon;
  final PokemonInfo? preloadedInfo;
  final String? preloadedLanguageCode;

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  late final PokemonDetailController controller;
  String? selectedEvolution;

  @override
  void initState() {
    super.initState();
    controller = PokemonDetailController(
      api: widget.api,
      favorites: widget.favorites,
      initialPokemon: widget.initialPokemon,
      preloadedInfo: widget.preloadedInfo,
      preloadedLanguageCode: widget.preloadedLanguageCode,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller.loadForLanguage(context.l10n.languageCode);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routes = PokemonDetailRoutes(
      context: context,
      api: widget.api,
      favorites: widget.favorites,
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _popWithHero();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121422),
        body: EvolutionHeroScope(
          selected: selectedEvolution,
          child: PokemonDetailLoader(
            loadMachines: widget.api.getMoveMachines,
            loadDescription: widget.api.getMoveDescription,
            loadBattleInfo: widget.api.getMoveBattleInfo,
            future: controller.future,
            initialPokemon: widget.initialPokemon,
            favorites: widget.favorites,
            selectedPage: controller.selectedPage,
            showShiny: controller.showShiny,
            scrollController: controller.scrollController,
            onRetry: _retry,
            onBack: _popWithHero,
            onFavorite: _toggle,
            onPlayCry: (pokemon) => _playCry(pokemon, routes),
            onShinyToggle: _toggleShiny,
            onPageSelected: _selectPage,
            onEvolutionTap: (species) => _openEvolution(species, routes),
          ),
        ),
      ),
    );
  }
}
