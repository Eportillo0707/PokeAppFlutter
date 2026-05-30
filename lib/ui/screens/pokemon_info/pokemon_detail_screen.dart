import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/composables/detail_header.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/composables/pokemon_detail_body.dart';
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
                return PokemonDetailBody(
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
