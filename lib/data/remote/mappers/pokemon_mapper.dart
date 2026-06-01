import 'package:pokeapp_flutter/data/remote/mappers/pokemon_evolution_mapper.dart';
import 'package:pokeapp_flutter/data/remote/mappers/pokemon_info_mapper.dart';
import 'package:pokeapp_flutter/data/remote/mappers/pokemon_item_mapper.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';

class PokemonMapper {
  const PokemonMapper({
    PokemonItemMapper itemMapper = const PokemonItemMapper(),
    PokemonInfoMapper infoMapper = const PokemonInfoMapper(),
    PokemonEvolutionMapper evolutionMapper = const PokemonEvolutionMapper(),
  })  : _itemMapper = itemMapper,
        _infoMapper = infoMapper,
        _evolutionMapper = evolutionMapper;

  final PokemonItemMapper _itemMapper;
  final PokemonInfoMapper _infoMapper;
  final PokemonEvolutionMapper _evolutionMapper;

  PokemonItem mapPokemonItem(Map<String, dynamic> detail) {
    return _itemMapper.map(detail);
  }

  PokemonInfo mapPokemonInfo({
    required Map<String, dynamic> pokemon,
    required Map<String, dynamic>? species,
    required Map<String, dynamic>? evolutionChain,
    required List<Map<String, dynamic>> abilities,
    required List<PokemonSpecies> megaEvolutions,
    String languageCode = 'en',
  }) {
    return _infoMapper.map(
      pokemon: pokemon,
      species: species,
      evolutionChain: evolutionChain,
      abilities: abilities,
      megaEvolutions: megaEvolutions,
      languageCode: languageCode,
    );
  }

  List<PokemonSpecies> mapEvolutionSpecies(
    Map<String, dynamic>? chain, {
    String languageCode = 'en',
  }) {
    return _evolutionMapper.map(chain, languageCode: languageCode);
  }

  List<PokemonSpecies> distinctSpecies(List<PokemonSpecies> species) {
    return _evolutionMapper.distinctSpecies(species);
  }
}
