import 'package:pokeapp_flutter/data/local/offline_catalog_database.dart';
import 'package:pokeapp_flutter/data/local/offline_pokemon_details.dart';
import 'package:pokeapp_flutter/data/local/offline_move_queries.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_generation.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_move.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';

class OfflinePokemonRepository implements PokemonRepository {
  OfflinePokemonRepository(this.catalog)
      : _details = OfflinePokemonDetails(catalog),
        _moves = OfflineMoveQueries(catalog);

  final OfflineCatalogDatabase catalog;
  final OfflinePokemonDetails _details;
  final OfflineMoveQueries _moves;

  @override
  Future<List<PokemonItem>> getPokemonList({int limit = 20, int offset = 0}) =>
      _items('p.is_default = 1', [], limit: limit, offset: offset);

  @override
  Future<List<PokemonItem>> searchPokemon(String query) {
    final value = query.trim().toLowerCase();
    if (value.isEmpty) return Future.value([]);
    return _items('p.name LIKE ? OR CAST(p.id AS TEXT) = ?',
        ['%$value%', value], limit: 40);
  }

  @override
  Future<List<PokemonItem>> getPokemonByType(String type) => _items(
      'EXISTS (SELECT 1 FROM pokemon_types pt JOIN types t ON t.id = pt.type_id '
      'WHERE pt.pokemon_id = p.id AND t.name = ?)', [type]);

  @override
  Future<List<PokemonItem>> getPokemonByGeneration(
    PokemonGeneration generation, {int limit = 20, int offset = 0}) =>
      _items('p.id BETWEEN ? AND ? AND p.is_default = 1',
          [generation.startId, generation.endId], limit: limit, offset: offset);

  Future<List<PokemonItem>> _items(String where, List<Object?> args,
      {int? limit, int offset = 0}) async {
    final rows = await catalog.query('SELECT p.id, p.name, '
        '(SELECT GROUP_CONCAT(name) FROM (SELECT t.name FROM pokemon_types pt '
        'JOIN types t ON t.id = pt.type_id WHERE pt.pokemon_id = p.id '
        'ORDER BY pt.slot)) AS types '
        'FROM pokemon p WHERE $where ORDER BY p.id '
        '${limit == null ? '' : 'LIMIT ? OFFSET ?'}',
        [...args, if (limit != null) ...[limit, offset]]);
    return rows.map((row) => PokemonItem(
      id: row['id'] as int,
      name: row['name'] as String,
      types: (row['types'] as String? ?? '').split(',').where((s) => s.isNotEmpty).toList(),
    )).toList();
  }

  @override
  Future<PokemonItem> getPokemonItem(String name) async {
    final rows = await _items('p.name = ? OR CAST(p.id AS TEXT) = ?',
        [name.toLowerCase(), name], limit: 1);
    if (rows.isEmpty) throw StateError('Pokémon not found: $name');
    return rows.first;
  }

  @override
  Future<PokemonInfo> getPokemonInfo(String name, {String languageCode = 'en'}) =>
      _details.load(name, languageCode);

  @override
  Future<MoveBattleInfo> getMoveBattleInfo(String move, String game, String language) =>
      _moves.battleInfo(move, game, language);

  @override
  Future<MoveDescription?> getMoveDescription(String move, String game, String language) =>
      _moves.description(move, game, language);

  @override
  Future<List<String>> getMoveMachines(String move, String game) =>
      _moves.machines(move, game);
}
