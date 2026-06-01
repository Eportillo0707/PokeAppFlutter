class PokemonTypeMapper {
  const PokemonTypeMapper();

  List<String> mapTypeNames(Map<String, dynamic> pokemon) {
    return sortedTypeSlots(pokemon)
        .map((slot) => slot['type']['name'] as String)
        .toList();
  }

  List<Map<String, dynamic>> sortedTypeSlots(Map<String, dynamic> pokemon) {
    return List<Map<String, dynamic>>.from(pokemon['types'] as List)
      ..sort((a, b) => (a['slot'] as int).compareTo(b['slot'] as int));
  }
}
