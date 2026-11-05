import 'package:pokeapp_flutter/domain/model/pokemon_move.dart';

class PokemonMoveMapper {
  const PokemonMoveMapper();

  List<PokemonMove> map(Map<String, dynamic> pokemon) {
    return (pokemon['moves'] as List? ?? []).map((entry) {
      final learning = <MoveLearning>[];
      final seen = <String>{};
      for (final detail in entry['version_group_details'] as List? ?? []) {
        final game = detail['version_group']['name'] as String;
        final method = detail['move_learn_method']['name'] as String;
        final level = detail['level_learned_at'] as int? ?? 0;
        if (!seen.add('$game/$method/$level')) continue;
        final url = Uri.parse(detail['version_group']['url'] as String);
        final id = int.tryParse(
              url.pathSegments.where((segment) => segment.isNotEmpty).last,
            ) ??
            0;
        learning.add(MoveLearning(
          game: game,
          gameId: id,
          method: method,
          level: level,
        ));
      }
      return PokemonMove(
          name: entry['move']['name'] as String, learning: learning);
    }).toList();
  }
}
