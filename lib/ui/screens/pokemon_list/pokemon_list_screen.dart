import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'package:pokeapp_flutter/ui/components/pokemon_widgets.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/pokemon_detail_screen.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/widgets/header_buttons.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/widgets/scroll_top_button.dart';
import 'package:pokeapp_flutter/ui/screens/search_pokemon/search_screen.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/type_screen.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({
    super.key,
    required this.api,
    required this.favorites,
  });

  final PokemonRepository api;
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
          ? ScrollTopButton(controller: controller)
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
                HeaderButtons(
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
