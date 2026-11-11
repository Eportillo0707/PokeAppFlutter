import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/data/remote/mappers/pokemon_move_mapper.dart';

void main() {
  const mapper = PokemonMoveMapper();

  test('preserves game, method and level, removing only exact duplicates', () {
    Map<String, dynamic> detail(
            String game, int id, String method, int level) =>
        {
          'version_group': {
            'name': game,
            'url': 'https://pokeapi.co/api/v2/version-group/$id/'
          },
          'move_learn_method': {'name': method},
          'level_learned_at': level,
        };
    final moves = mapper.map({
      'moves': [
        {
          'move': {'name': 'thunderbolt'},
          'version_group_details': [
            detail('red-blue', 1, 'machine', 0),
            detail('red-blue', 1, 'machine', 0),
            detail('yellow', 2, 'level-up', 26),
            detail('yellow', 2, 'machine', 0),
            detail('yellow', 2, 'level-up', 30),
          ]
        },
      ]
    });
    expect(moves.single.name, 'thunderbolt');
    expect(moves.single.learning.length, 4);
    expect(moves.single.learning[1].game, 'yellow');
    expect(moves.single.learning[1].gameId, 2);
    expect(moves.single.learning[1].method, 'level-up');
    expect(moves.single.learning[1].level, 26);
  });

  test('supports absent moves and empty learnsets for alternate forms', () {
    expect(mapper.map({}), isEmpty);
    expect(
        mapper
            .map({
              'moves': [
                {
                  'move': {'name': 'tackle'},
                  'version_group_details': []
                },
              ]
            })
            .single
            .learning,
        isEmpty);
  });
}
