import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'package:pokeapp_flutter/ui/components/pokemon_widgets.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/pokemon_detail_screen.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/type_screen.dart';

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
                  return PokemonGrid(
                    items: results,
                    favorites: widget.favorites,
                    onPokemonTap: _openDetail,
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
              builder: (_) => TypePickerSheet(
                useImages: true,
                onSelected: (type) {
                  Navigator.pop(context);
                  onTypeSelected(type);
                },
              ),
            ),
            icon: const Icon(Icons.tune, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}
