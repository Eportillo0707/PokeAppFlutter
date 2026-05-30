import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';

class FavoritesStore extends ChangeNotifier {
  static const _storageKey = 'favorite_pokemon';
  final Map<int, PokemonItem> _favorites = {};
  bool _loaded = false;

  List<PokemonItem> get items {
    final list = _favorites.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return list;
  }

  bool isFavorite(int id) => _favorites.containsKey(id);

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final data = jsonDecode(raw) as List<dynamic>;
      for (final item in data) {
        final pokemon = PokemonItem.fromJson(item as Map<String, dynamic>);
        pokemon.isFavorite = true;
        _favorites[pokemon.id] = pokemon;
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggle(PokemonItem pokemon) async {
    await load();
    if (_favorites.containsKey(pokemon.id)) {
      _favorites.remove(pokemon.id);
    } else {
      pokemon.isFavorite = true;
      _favorites[pokemon.id] = pokemon;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((pokemon) => pokemon.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }
}
