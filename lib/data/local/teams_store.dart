import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_team.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';

class TeamsStore extends ChangeNotifier {
  static const storageKey = 'pokemon_teams_v1';
  List<PokemonTeam> _items = [];
  Future<void>? _loading;
  Future<void> _queue = Future.value();
  List<PokemonTeam> get items => List.unmodifiable(_items);
  PokemonTeam? find(String id) {
    for (final team in _items) {
      if (team.id == id) return team;
    }
    return null;
  }

  Future<void> load() => _loading ??= _load().catchError((Object error) {
        _loading = null;
        throw error;
      });
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw != null) {
      _items = (jsonDecode(raw) as List)
          .map((entry) =>
              PokemonTeam.fromJson(Map<String, dynamic>.from(entry as Map)))
          .toList();
    }
    notifyListeners();
  }

  Future<void> _change(List<PokemonTeam> Function() update) {
    final operation = _queue.then((_) async {
      await load();
      final next = update();
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setString(
          storageKey, jsonEncode(next.map((t) => t.toJson()).toList()));
      if (!saved) throw StateError('Team save failed');
      _items = next;
      notifyListeners();
    });
    _queue = operation.catchError((Object _) {});
    return operation;
  }

  Future<String> create(String name) async {
    final random = Random.secure();
    final id = List.generate(
            16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'))
        .join();
    await _change(() => [..._items, PokemonTeam(id: id, name: _name(name))]);
    return id;
  }

  String _name(String value) {
    final name = value.trim();
    if (name.isEmpty || name.length > 40) {
      throw ArgumentError('Invalid team name');
    }
    return name;
  }

  Future<void> rename(String id, String name) => _change(() => [
        for (final t in _items) t.id == id ? t.copyWith(name: _name(name)) : t,
      ]);
  Future<void> delete(String id) =>
      _change(() => _items.where((t) => t.id != id).toList());
  Future<void> add(String id, PokemonItem pokemon) => _change(() {
        final team = find(id);
        if (team == null) throw StateError('Missing team');
        if (team.members.length >= 6) throw StateError('Team is full');
        if (team.members.any((p) => p.id == pokemon.id)) {
          throw StateError('Duplicate member');
        }
        return [
          for (final t in _items)
            t.id == id ? t.copyWith(members: [...t.members, pokemon]) : t
        ];
      });
  Future<void> remove(String id, int pokemonId) => _change(() => [
        for (final t in _items)
          t.id == id
              ? t.copyWith(
                  members: t.members.where((p) => p.id != pokemonId).toList())
              : t,
      ]);
}
