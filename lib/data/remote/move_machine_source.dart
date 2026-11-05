import 'pokemon_remote_data_source.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_move.dart';

/// Resolves actual items for the selected game; never infers from generation.
class MoveMachineSource {
  MoveMachineSource(this.remote);

  final PokemonRemoteDataSource remote;
  final _cache = <String, Future<Map<String, dynamic>>>{};
  final _queues = List<Future<void>>.generate(4, (_) => Future.value());
  int _nextQueue = 0;

  Future<MoveBattleInfo> getBattleInfo(
      String move, String game, String language) async {
    final data = await _get(
        'https://pokeapi.co/api/v2/move/${Uri.encodeComponent(move)}/');
    final version = await _get(
        'https://pokeapi.co/api/v2/version-group/${Uri.encodeComponent(game)}/');
    final order = version['order'] as int;
    var power = data['power'] as int?;
    var pp = data['pp'] as int?;
    var accuracy = data['accuracy'] as int?;
    var type = data['type']['name'] as String;
    final changes = <(int, Map<String, dynamic>)>[];
    for (final change in List<Map<String, dynamic>>.from(
        data['past_values'] as List? ?? [])) {
      final changedVersion =
          await _get(change['version_group']['url'] as String);
      final changedOrder = changedVersion['order'] as int;
      if (changedOrder > order) changes.add((changedOrder, change));
    }
    // The API records old values at the version where they changed.
    // Rewind each changed field from newest to oldest, preserving unchanged fields.
    changes.sort((a, b) => b.$1.compareTo(a.$1));
    for (final (_, change) in changes) {
      power = change['power'] as int? ?? power;
      pp = change['pp'] as int? ?? pp;
      accuracy = change['accuracy'] as int? ?? accuracy;
      type = change['type']?['name'] as String? ?? type;
    }
    var category = data['damage_class']['name'] as String;
    final generation = int.tryParse((version['generation']['url'] as String)
            .split('/')
            .where((s) => s.isNotEmpty)
            .last) ??
        0;
    if (generation > 0 && generation <= 3 && category != 'status') {
      category = const {
        'normal',
        'fighting',
        'flying',
        'poison',
        'ground',
        'rock',
        'bug',
        'ghost',
        'steel'
      }.contains(type)
          ? 'physical'
          : 'special';
    }
    var name = move
        .split('-')
        .map((s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}')
        .join(' ');
    for (final entry in data['names'] as List? ?? []) {
      if (entry['language']['name'] == language) {
        name = entry['name'] as String;
        break;
      }
    }
    return MoveBattleInfo(
        name: name,
        type: type,
        category: category,
        power: power,
        pp: pp,
        generation: data['generation']?['name'] as String?,
        accuracy: accuracy);
  }

  Future<MoveDescription?> getDescription(
      String move, String game, String language) async {
    final data = await _get(
        'https://pokeapi.co/api/v2/move/${Uri.encodeComponent(move)}/');
    final entries = List<Map<String, dynamic>>.from(
        data['flavor_text_entries'] as List? ?? []);
    // Prefer the requested language and game. Any fallback retains its source
    // so the UI never presents another game's text as belonging to this game.
    for (final lang in {language, 'en'}) {
      final localized = entries
          .where((entry) =>
              entry['language']?['name'] == lang &&
              (entry['flavor_text'] as String? ?? '').trim().isNotEmpty)
          .toList();
      if (localized.isEmpty) continue;
      final exact =
          localized.where((entry) => entry['version_group']?['name'] == game);
      final entry = exact.isNotEmpty ? exact.first : localized.last;
      return MoveDescription(
        text: (entry['flavor_text'] as String)
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim(),
        game: entry['version_group']['name'] as String,
        language: lang,
      );
    }
    return null;
  }

  Future<Map<String, dynamic>> _get(String url) {
    return _cache.putIfAbsent(url, () {
      final slot = _nextQueue++ % _queues.length;
      final request = _queues[slot].then((_) =>
          remote.getAbsoluteJson(url).timeout(const Duration(seconds: 15)));
      _queues[slot] =
          request.then<void>((_) {}, onError: (Object _, StackTrace __) {});
      return request.catchError((Object error, StackTrace stack) {
        _cache.remove(url);
        Error.throwWithStackTrace(error, stack);
      });
    });
  }

  Future<List<String>> getMachines(String move, String game) async {
    final data = await _get(
        'https://pokeapi.co/api/v2/move/${Uri.encodeComponent(move)}/');
    final items = <String>{};
    for (final entry in data['machines'] as List? ?? []) {
      if (entry['version_group']['name'] != game) continue;
      final machine = await _get(entry['machine']['url'] as String);
      if (machine['version_group']?['name'] != game ||
          machine['move']?['name'] != move) {
        continue;
      }
      final name = machine['item']?['name'] as String?;
      if (name != null && RegExp(r'^(tm|hm|tr)\d+$').hasMatch(name)) {
        items.add(name);
      }
    }
    return items.toList()..sort();
  }
}
