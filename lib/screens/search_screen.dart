import 'package:flutter/material.dart';

import '../models/pokemon_models.dart';
import '../services/favorites_store.dart';
import '../services/pokeapi_client.dart';
import '../utils/pokemon_formatters.dart';
import '../widgets/pokemon_widgets.dart';
import 'pokemon_detail_screen.dart';
import 'type_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.api,
    required this.favorites,
  });

  final PokeApiClient api;
  final FavoritesStore favorites;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  int searchGeneration = 0;
  List<PokemonItem> results = [];
  bool loading = false;
  bool searched = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onQueryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    controller.removeListener(_onQueryChanged);
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final query = controller.text.trim();
    final generation = ++searchGeneration;
    if (query.isEmpty) {
      setState(() {
        loading = false;
        searched = false;
        results = [];
      });
      return;
    }
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (!mounted || generation != searchGeneration) return;
      _search();
    });
  }

  Future<void> _search() async {
    final query = controller.text.trim();
    if (query.isEmpty) return;
    final generation = searchGeneration;
    setState(() {
      loading = true;
      searched = true;
    });
    try {
      final next = await widget.api.searchPokemon(query);
      if (!mounted || generation != searchGeneration) return;
      setState(() => results = next);
    } finally {
      if (mounted && generation == searchGeneration) {
        setState(() => loading = false);
      }
    }
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
        child: Column(
          children: [
            const SizedBox(height: 10),
            _SearchPokemonBar(
              controller: controller,
              focusNode: focusNode,
              onTypeSelected: _openType,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: AnimatedBuilder(
                animation: widget.favorites,
                builder: (context, _) {
                  if (loading) return const LoadingState();
                  if (searched && results.isEmpty) {
                    return const Center(child: Text('Sin resultados'));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: .82,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final pokemon = results[index]
                        ..isFavorite =
                            widget.favorites.isFavorite(results[index].id);
                      return PokemonCard(
                        pokemon: pokemon,
                        onTap: () => _openDetail(pokemon),
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

class _SearchPokemonBar extends StatelessWidget {
  const _SearchPokemonBar({
    required this.controller,
    required this.focusNode,
    required this.onTypeSelected,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      height: 36,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onSubmitted: (_) {},
        style: const TextStyle(color: Colors.white, fontSize: 14),
        cursorColor: Colors.white,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF232B4C),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: .5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: .5),
          ),
          hintText: 'Search',
          hintStyle: const TextStyle(color: Colors.white),
          prefixIcon: const Icon(Icons.search, color: Colors.white, size: 18),
          suffixIcon: IconButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              backgroundColor: const Color(0xFF232B4C),
              builder: (_) => _FilterContent(onTypeSelected: onTypeSelected),
            ),
            icon: const Icon(Icons.tune, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

class _FilterContent extends StatelessWidget {
  const _FilterContent({required this.onTypeSelected});

  final ValueChanged<String> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select a Type',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 15),
            GridView.builder(
              shrinkWrap: true,
              itemCount: pokemonTypes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final type = pokemonTypes[index];
                return IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onTypeSelected(type);
                  },
                  icon: TypeBadgeImage(type: type, width: 78),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
