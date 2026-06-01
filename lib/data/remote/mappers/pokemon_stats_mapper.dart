import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';

class PokemonStatsMapper {
  const PokemonStatsMapper();

  List<PokemonStat> map(Map<String, dynamic> pokemon) {
    return List<Map<String, dynamic>>.from(pokemon['stats'] as List)
        .map(
          (slot) => PokemonStat(
            name: slot['stat']['name'] as String,
            baseStat: slot['base_stat'] as int,
          ),
        )
        .toList();
  }
}
