import 'package:pokeapp_flutter/data/remote/mappers/pokemon_type_mapper.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';

class PokemonItemMapper {
  const PokemonItemMapper({
    PokemonTypeMapper typeMapper = const PokemonTypeMapper(),
  }) : _typeMapper = typeMapper;

  final PokemonTypeMapper _typeMapper;

  PokemonItem map(Map<String, dynamic> detail) {
    return PokemonItem(
      id: detail['id'] as int,
      name: detail['name'] as String,
      types: _typeMapper.mapTypeNames(detail),
    );
  }
}
