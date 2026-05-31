import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_generation.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'package:pokeapp_flutter/ui/components/pokemon_widgets.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/pokemon_detail_screen.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/widgets/generation_filter_sheet.dart';
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
  static const _pageSize = 20;

  final controller = ScrollController();
  final showScrollTop = ValueNotifier(false);
  final items = <PokemonItem>[];
  bool loading = true;
  bool loadingMore = false;
  bool hasError = false;
  bool hasMore = true;
  PokemonGeneration? selectedGeneration;
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
    showScrollTop.dispose();
    super.dispose();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      loading = true;
      hasError = false;
      hasMore = true;
      offset = 0;
      items.clear();
    });
    try {
      final page = selectedGeneration == null
          ? await widget.api.getPokemonList(limit: _pageSize, offset: offset)
          : await widget.api.getPokemonByGeneration(
              selectedGeneration!,
              limit: _pageSize,
              offset: offset,
            );
      setState(() {
        items.addAll(page);
        offset += page.length;
        hasMore = page.length == _pageSize;
      });
    } catch (_) {
      setState(() => hasError = true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (loadingMore || loading || !hasMore) return;
    setState(() => loadingMore = true);
    try {
      final page = selectedGeneration == null
          ? await widget.api.getPokemonList(limit: _pageSize, offset: offset)
          : await widget.api.getPokemonByGeneration(
              selectedGeneration!,
              limit: _pageSize,
              offset: offset,
            );
      setState(() {
        items.addAll(page);
        offset += page.length;
        hasMore = page.length == _pageSize;
      });
    } finally {
      if (mounted) setState(() => loadingMore = false);
    }
  }

  void _onScroll() {
    final shouldShowScrollTop =
        controller.hasClients && controller.position.pixels > 240;
    if (showScrollTop.value != shouldShowScrollTop) {
      showScrollTop.value = shouldShowScrollTop;
    }
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
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: showScrollTop,
        builder: (context, visible, child) =>
            visible ? child! : const SizedBox(),
        child: ScrollTopButton(controller: controller),
      ),
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
                  onGenerationFilter: _showGenerationPicker,
                  hasGenerationFilter: selectedGeneration != null,
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

  void _showGenerationPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF121422),
      isScrollControlled: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: .72,
        child: GenerationFilterSheet(
          selectedGeneration: selectedGeneration,
          onSelected: (generation) {
            Navigator.pop(context);
            setState(() => selectedGeneration = generation);
            if (controller.hasClients) controller.jumpTo(0);
            _loadFirstPage();
          },
        ),
      ),
    );
  }
}
