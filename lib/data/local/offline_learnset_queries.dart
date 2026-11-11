import 'package:pokeapp_flutter/data/local/offline_catalog_database.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_move.dart';

class OfflineLearnsetQueries {
  OfflineLearnsetQueries(this.catalog);
  final OfflineCatalogDatabase catalog;

  Future<List<PokemonMove>> forPokemon(int id) async {
    final rows = await catalog.query('SELECT m.name AS move, g.name AS game, '
        'g.id AS game_id, l.method, l.level FROM learnsets l '
        'JOIN moves m ON m.id = l.move_id JOIN games g ON g.id = l.game_id '
        'WHERE l.pokemon_id = ? ORDER BY m.id, g.id, l.method, l.level', [id]);
    final learning = <String, List<MoveLearning>>{};
    for (final row in rows) {
      (learning[row['move'] as String] ??= []).add(MoveLearning(
        game: row['game'] as String,
        gameId: row['game_id'] as int,
        method: row['method'] as String,
        level: row['level'] as int,
      ));
    }
    return [for (final entry in learning.entries)
      PokemonMove(name: entry.key, learning: entry.value)];
  }
}
