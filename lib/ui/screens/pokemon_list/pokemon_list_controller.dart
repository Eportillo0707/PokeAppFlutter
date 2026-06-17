import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_generation.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/generation_starter_precache.dart';

part 'pokemon_list_controller_fetch.dart';

class PokemonListController extends ChangeNotifier {
  PokemonListController({required this.api});

  static const pageSize = 20;

  final PokemonRepository api;
  final scrollController = ScrollController();
  final showScrollTop = ValueNotifier(false);
  final items = <PokemonItem>[];

  bool loading = true;
  bool loadingMore = false;
  bool hasError = false;
  bool hasMore = true;
  PokemonGeneration? selectedGeneration;
  int offset = 0;
  Future<void>? _generationStarterPrecache;

  void init(BuildContext context) {
    loadFirstPage();
    scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generationStarterPrecache = precacheGenerationStarterImages(context);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    showScrollTop.dispose();
    super.dispose();
  }

  Future<void> loadFirstPage() async {
    loading = true;
    hasError = false;
    hasMore = true;
    offset = 0;
    items.clear();
    notifyListeners();
    try {
      final page = await _fetchPage();
      items.addAll(page);
      offset += page.length;
      hasMore = page.length == pageSize;
    } catch (_) {
      hasError = true;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (loadingMore || loading || !hasMore) return;
    loadingMore = true;
    notifyListeners();
    try {
      final page = await _fetchPage();
      items.addAll(page);
      offset += page.length;
      hasMore = page.length == pageSize;
    } finally {
      loadingMore = false;
      notifyListeners();
    }
  }

  Future<void> selectGeneration(PokemonGeneration? generation) async {
    selectedGeneration = generation;
    if (scrollController.hasClients) scrollController.jumpTo(0);
    await loadFirstPage();
  }

  Future<void> ensureGenerationImagesReady(BuildContext context) {
    _generationStarterPrecache ??= precacheGenerationStarterImages(context);
    return _generationStarterPrecache!;
  }

  void _onScroll() {
    final shouldShow =
        scrollController.hasClients && scrollController.position.pixels > 240;
    if (showScrollTop.value != shouldShow) showScrollTop.value = shouldShow;
    if (scrollController.position.pixels >
        scrollController.position.maxScrollExtent - 480) {
      loadMore();
    }
  }
}
