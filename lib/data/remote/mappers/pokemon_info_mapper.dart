import 'package:pokeapp_flutter/data/remote/mappers/localized_text_mapper.dart';
import 'package:pokeapp_flutter/data/remote/mappers/pokemon_ability_mapper.dart';
import 'package:pokeapp_flutter/data/remote/mappers/pokemon_evolution_mapper.dart';
import 'package:pokeapp_flutter/data/remote/mappers/pokemon_stats_mapper.dart';
import 'package:pokeapp_flutter/data/remote/mappers/pokemon_type_mapper.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';

class PokemonInfoMapper {
  const PokemonInfoMapper({
    PokemonStatsMapper statsMapper = const PokemonStatsMapper(),
    PokemonTypeMapper typeMapper = const PokemonTypeMapper(),
    PokemonAbilityMapper abilityMapper = const PokemonAbilityMapper(),
    PokemonEvolutionMapper evolutionMapper = const PokemonEvolutionMapper(),
    LocalizedTextMapper textMapper = const LocalizedTextMapper(),
  })  : _statsMapper = statsMapper,
        _typeMapper = typeMapper,
        _abilityMapper = abilityMapper,
        _evolutionMapper = evolutionMapper,
        _textMapper = textMapper;

  final PokemonStatsMapper _statsMapper;
  final PokemonTypeMapper _typeMapper;
  final PokemonAbilityMapper _abilityMapper;
  final PokemonEvolutionMapper _evolutionMapper;
  final LocalizedTextMapper _textMapper;

  PokemonInfo map({
    required Map<String, dynamic> pokemon,
    required Map<String, dynamic>? species,
    required Map<String, dynamic>? evolutionChain,
    required List<Map<String, dynamic>> abilities,
    required List<PokemonSpecies> megaEvolutions,
    String languageCode = 'en',
  }) {
    final evolutions = [
      ..._evolutionMapper.map(evolutionChain, languageCode: languageCode),
      ...megaEvolutions,
    ];

    return PokemonInfo(
      id: pokemon['id'] as int,
      name: pokemon['name'] as String,
      height: pokemon['height'] as int? ?? 0,
      weight: pokemon['weight'] as int? ?? 0,
      baseExperience: pokemon['base_experience'] as int? ?? 0,
      stats: _statsMapper.map(pokemon),
      types: _typeMapper.mapTypeNames(pokemon),
      evolutionChain: _evolutionMapper.distinctSpecies(evolutions),
      megaEvolutions: megaEvolutions,
      abilities: _abilityMapper.map(pokemon, abilities, languageCode),
      description: _textMapper.flavorText(
        species?['flavor_text_entries'],
        languageCode,
      ),
      cryUrl: _cryUrl(pokemon),
    );
  }

  String? _cryUrl(Map<String, dynamic> pokemon) {
    final cries = pokemon['cries'];
    if (cries is! Map<String, dynamic>) return null;
    return (cries['latest'] as String?) ?? (cries['legacy'] as String?);
  }
}
