import 'package:pokeapp_flutter/data/local/offline_catalog_database.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_move.dart';

class OfflineMoveQueries {
  OfflineMoveQueries(this.catalog);
  final OfflineCatalogDatabase catalog;

  Future<MoveBattleInfo> battleInfo(String move, String game, String language) async {
    final rows = await catalog.query('SELECT m.*, t.name AS type, '
        'g.sort_order AS game_order, g.generation_id AS game_generation, '
        'gen.name AS generation, COALESCE(n.name, m.name) AS localized_name '
        'FROM moves m JOIN types t ON t.id = m.type_id '
        'JOIN generations gen ON gen.id = m.generation_id '
        'JOIN games g ON g.name = ? '
        'LEFT JOIN move_names n ON n.move_id = m.id AND n.language = ? '
        'WHERE m.name = ?', [game, language, move]);
    if (rows.isEmpty) throw StateError('Move not found: $move / $game');
    final row = rows.first;
    var power = row['power'] as int?;
    var accuracy = row['accuracy'] as int?;
    var pp = row['pp'] as int?;
    var type = row['type'] as String;
    final changes = await catalog.query('SELECT v.*, t.name AS type '
        'FROM move_past_values v JOIN games g ON g.id = v.game_id '
        'LEFT JOIN types t ON t.id = v.type_id '
        'WHERE v.move_id = ? AND g.sort_order > ? ORDER BY g.sort_order DESC',
        [row['id'], row['game_order']]);
    for (final change in changes) {
      power = change['power'] as int? ?? power;
      accuracy = change['accuracy'] as int? ?? accuracy;
      pp = change['pp'] as int? ?? pp;
      type = change['type'] as String? ?? type;
    }
    var category = row['category'] as String;
    if ((row['game_generation'] as int) <= 3 && category != 'status') {
      category = const {'normal', 'fighting', 'flying', 'poison', 'ground',
        'rock', 'bug', 'ghost', 'steel'}.contains(type) ? 'physical' : 'special';
    }
    return MoveBattleInfo(name: row['localized_name'] as String, type: type,
        category: category, power: power, accuracy: accuracy, pp: pp,
        generation: row['generation'] as String);
  }

  Future<MoveDescription?> description(String move, String game, String language) async {
    final exact = await catalog.query('SELECT d.description, g.name AS game, '
        'd.language FROM move_descriptions d JOIN moves m ON m.id = d.move_id '
        'JOIN games g ON g.id = d.game_id WHERE m.name = ? AND g.name = ? '
        'AND d.language = ? LIMIT 1', [move, game, language]);
    final rows = exact.isNotEmpty ? exact : await catalog.query(
        'SELECT d.description, g.name AS game, d.language FROM move_descriptions d '
        'JOIN moves m ON m.id = d.move_id JOIN games g ON g.id = d.game_id '
        'WHERE m.name = ? AND d.language IN (?, ?) '
        'ORDER BY CASE WHEN d.language = ? THEN 0 ELSE 1 END, '
        'g.sort_order DESC LIMIT 1', [move, language, 'en', language]);
    if (rows.isEmpty) return null;
    final row = rows.first;
    return MoveDescription(text: row['description'] as String,
        game: row['game'] as String, language: row['language'] as String);
  }

  Future<List<String>> machines(String move, String game) async {
    final rows = await catalog.query('SELECT DISTINCT ma.item_name FROM machines ma '
        'JOIN moves m ON m.id = ma.move_id JOIN games g ON g.id = ma.game_id '
        'WHERE m.name = ? AND g.name = ? ORDER BY ma.item_name', [move, game]);
    return rows.map((row) => row['item_name'] as String).toList();
  }
}
