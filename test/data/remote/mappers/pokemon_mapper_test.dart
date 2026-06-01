import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/data/remote/mappers/pokemon_mapper.dart';

void main() {
  test('mapEvolutionSpecies preserves chain order when ids are not sequential',
      () {
    const mapper = PokemonMapper();
    final species = mapper.mapEvolutionSpecies(_electabuzzEvolutionChain);

    expect(
      species.map((item) => item.name),
      ['elekid', 'electabuzz', 'electivire'],
    );
    expect(species[1].evolvesFromSpeciesId, 239);
    expect(species[2].evolvesFromSpeciesId, 125);
  });
}

const _electabuzzEvolutionChain = {
  'chain': {
    'species': {
      'name': 'elekid',
      'url': 'https://pokeapi.co/api/v2/pokemon-species/239/',
    },
    'evolution_details': [],
    'evolves_to': [
      {
        'species': {
          'name': 'electabuzz',
          'url': 'https://pokeapi.co/api/v2/pokemon-species/125/',
        },
        'evolution_details': [
          {
            'min_level': 30,
          },
        ],
        'evolves_to': [
          {
            'species': {
              'name': 'electivire',
              'url': 'https://pokeapi.co/api/v2/pokemon-species/466/',
            },
            'evolution_details': [
              {
                'trigger': {'name': 'trade'},
                'held_item': {'name': 'electirizer'},
              },
            ],
            'evolves_to': [],
          },
        ],
      },
    ],
  },
};
