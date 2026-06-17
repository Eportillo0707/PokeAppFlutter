import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';

class PokemonSearchController extends ChangeNotifier {
  PokemonSearchController({required this.api});

  final PokemonRepository api;
  final textController = TextEditingController();
  final focusNode = FocusNode();
  int _generation = 0;
  List<PokemonItem> results = [];
  bool loading = false;
  bool searched = false;

  void init() {
    textController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    textController.removeListener(_onQueryChanged);
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void requestFocus() => focusNode.requestFocus();

  void _onQueryChanged() {
    final query = textController.text.trim();
    final generation = ++_generation;
    if (query.isEmpty) {
      loading = false;
      searched = false;
      results = [];
      notifyListeners();
      return;
    }
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (generation == _generation) search(generation);
    });
  }

  Future<void> search(int generation) async {
    final query = textController.text.trim();
    if (query.isEmpty) return;
    loading = true;
    searched = true;
    notifyListeners();
    try {
      final next = await api.searchPokemon(query);
      if (generation != _generation) return;
      results = next;
    } finally {
      if (generation == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }
}
