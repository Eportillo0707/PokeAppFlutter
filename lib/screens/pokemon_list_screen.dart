import 'package:flutter/material.dart';

import '../models/pokemon_models.dart';
import '../services/favorites_store.dart';
import '../services/pokeapi_client.dart';
import '../widgets/pokemon_widgets.dart';
import 'pokemon_detail_screen.dart';
import 'search_screen.dart';
import 'type_screen.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({
    super.key,
    required this.api,
    required this.favorites,
  });

  final PokeApiClient api;
  final FavoritesStore favorites;

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final controller = ScrollController();
  final items = <PokemonItem>[];
  bool loading = true;
  bool loadingMore = false;
  bool hasError = false;
  int offset = 0;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
    controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      loading = true;
      hasError = false;
      offset = 0;
      items.clear();
    });
    try {
      final page = await widget.api.getPokemonList(offset: offset);
      setState(() {
        items.addAll(page);
        offset += page.length;
      });
    } catch (_) {
      setState(() => hasError = true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (loadingMore || loading) return;
    setState(() => loadingMore = true);
    try {
      final page = await widget.api.getPokemonList(offset: offset);
      setState(() {
        items.addAll(page);
        offset += page.length;
      });
    } finally {
      if (mounted) setState(() => loadingMore = false);
    }
  }

  void _onScroll() {
    if (mounted) setState(() {});
    if (controller.position.pixels >
        controller.position.maxScrollExtent - 480) {
      _loadMore();
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
      floatingActionButton: controller.hasClients && controller.offset > 240
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF232B4C),
              onPressed: () => controller.animateTo(
                0,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
              ),
              child: const Icon(Icons.arrow_upward),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: widget.favorites,
          builder: (context, _) {
            if (loading) return const LoadingState();
            if (hasError) return ErrorState(onRetry: _loadFirstPage);
            return Column(
              children: [
                const SizedBox(height: 10),
                _HeaderButtons(
                  onSearch: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SearchScreen(
                        api: widget.api,
                        favorites: widget.favorites,
                      ),
                    ),
                  ),
                  onFilter: _showTypePicker,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadFirstPage,
                    child: PokemonGrid(
                      controller: controller,
                      items: items,
                      favorites: widget.favorites,
                      loadingMore: loadingMore,
                      onPokemonTap: _openDetail,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showTypePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF232B4C),
      builder: (_) => TypePickerSheet(
        onSelected: (type) {
          Navigator.pop(context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TypeScreen(
                api: widget.api,
                favorites: widget.favorites,
                type: type,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeaderButtons extends StatelessWidget {
  const _HeaderButtons({required this.onSearch, required this.onFilter});

  final VoidCallback onSearch;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 350,
        height: 38,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onSearch,
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFF232B4C),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.grey, width: .5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 44,
              child: OutlinedButton(
                onPressed: onFilter,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: const Color(0xFF232B4C),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.grey, width: .5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.tune, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
