part of 'move_machine_source.dart';

extension MoveMachineSourceMethods on MoveMachineSource {
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
