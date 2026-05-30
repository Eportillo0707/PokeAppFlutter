import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'package:pokeapp_flutter/domain/usecases/type_effectiveness.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/composables/detail_about.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/composables/detail_card.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/composables/detail_evolutions.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/composables/detail_header.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/composables/detail_stats.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/composables/detail_tabs.dart';
import 'package:pokeapp_flutter/ui/components/pokemon_widgets.dart';

class PokemonDetailScreen extends StatefulWidget {
  const PokemonDetailScreen({
    super.key,
    required this.api,
    required this.favorites,
    required this.initialPokemon,
  });

  final PokemonRepository api;
  final FavoritesStore favorites;
  final PokemonItem initialPokemon;

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  late Future<PokemonInfo> future;
  final detailScrollController = ScrollController();
  int selectedPage = 0;
  bool isPopping = false;

  @override
  void initState() {
    super.initState();
    future = widget.api.getPokemonInfo(widget.initialPokemon.name);
  }

  @override
  void dispose() {
    detailScrollController.dispose();
    super.dispose();
  }

  Future<void> _toggle(PokemonInfo pokemon) async {
    await widget.favorites.toggle(pokemon.toItem());
    setState(
      () => pokemon.isFavorite = widget.favorites.isFavorite(pokemon.id),
    );
  }

  Future<void> _popWithHero() async {
    if (isPopping) return;
    isPopping = true;

    if (detailScrollController.hasClients &&
        detailScrollController.offset > 12) {
      await detailScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  void _openEvolution(PokemonSpecies species) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PokemonDetailScreen(
          api: widget.api,
          favorites: widget.favorites,
          initialPokemon: PokemonItem(
            id: species.id,
            name: species.name,
            types: const [],
          ),
        ),
      ),
    );
  }

  void _selectPage(int page) => setState(() => selectedPage = page);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _popWithHero();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121422),
        body: FutureBuilder<PokemonInfo>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return DetailHeaderLoading(
                initialPokemon: widget.initialPokemon,
                onBack: _popWithHero,
              );
            }
            if (snapshot.hasError) {
              return ErrorState(
                onRetry: () => setState(
                  () => future =
                      widget.api.getPokemonInfo(widget.initialPokemon.name),
                ),
              );
            }
            final pokemon = snapshot.data!
              ..isFavorite = widget.favorites.isFavorite(snapshot.data!.id);
            return AnimatedBuilder(
              animation: widget.favorites,
              builder: (context, _) {
                pokemon.isFavorite = widget.favorites.isFavorite(pokemon.id);
                return _PokemonDetailBody(
                  pokemon: pokemon,
                  selectedPage: selectedPage,
                  scrollController: detailScrollController,
                  onBack: _popWithHero,
                  onFavorite: () => _toggle(pokemon),
                  onPageSelected: _selectPage,
                  onEvolutionTap: _openEvolution,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PokemonDetailBody extends StatelessWidget {
  const _PokemonDetailBody({
    required this.pokemon,
    required this.selectedPage,
    required this.scrollController,
    required this.onBack,
    required this.onFavorite,
    required this.onPageSelected,
    required this.onEvolutionTap,
  });

  final PokemonInfo pokemon;
  final int selectedPage;
  final ScrollController scrollController;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final ValueChanged<int> onPageSelected;
  final ValueChanged<PokemonSpecies> onEvolutionTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            DetailHeader(
              pokemon: pokemon,
              onBack: onBack,
              onFavorite: onFavorite,
            ),
            PokemonDetailTypeBadges(types: pokemon.types),
            const SizedBox(height: 14),
            DetailTabs(
              selectedPage: selectedPage,
              onInfoClick: () => onPageSelected(0),
              onStatsClick: () => onPageSelected(1),
            ),
            DetailPageCard(
              child: _SwipeableDetailPage(
                selectedPage: selectedPage,
                onPageSelected: onPageSelected,
                child: selectedPage == 0
                    ? _InfoPage(
                        pokemon: pokemon,
                        onEvolutionTap: onEvolutionTap,
                      )
                    : _StatsPage(pokemon: pokemon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeableDetailPage extends StatelessWidget {
  const _SwipeableDetailPage({
    required this.selectedPage,
    required this.onPageSelected,
    required this.child,
  });

  final int selectedPage;
  final ValueChanged<int> onPageSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -120 && selectedPage == 0) {
          onPageSelected(1);
        } else if (velocity > 120 && selectedPage == 1) {
          onPageSelected(0);
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          final offset = Tween<Offset>(
            begin: Offset(selectedPage == 0 ? -0.08 : 0.08, 0),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offset, child: child),
          );
        },
        child: child,
      ),
    );
  }
}

class _InfoPage extends StatelessWidget {
  const _InfoPage({
    required this.pokemon,
    required this.onEvolutionTap,
  });

  final PokemonInfo pokemon;
  final ValueChanged<PokemonSpecies> onEvolutionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('info-page'),
      children: [
        PokemonDescriptionPanel(pokemon: pokemon),
        PokemonSpecsPanel(pokemon: pokemon),
        PokemonAbilitiesPanel(pokemon: pokemon),
        PokemonEvolutionsPanel(
          pokemon: pokemon,
          onSpeciesTap: onEvolutionTap,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _StatsPage extends StatelessWidget {
  const _StatsPage({required this.pokemon});

  final PokemonInfo pokemon;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('stats-page'),
      children: [
        PokemonStatsPanel(pokemon: pokemon),
        PokemonTypeEffectivenessPanel(
          effectiveness: getDefensiveEffectiveness(pokemon.types),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
