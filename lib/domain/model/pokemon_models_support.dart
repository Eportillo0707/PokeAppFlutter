class PokemonStat {
  const PokemonStat({required this.name, required this.baseStat});

  final String name;
  final int baseStat;
}

class PokemonAbility {
  const PokemonAbility({required this.name, required this.flavorText});

  final String name;
  final String flavorText;
}

class PokemonSpecies {
  const PokemonSpecies({
    required this.id,
    required this.name,
    this.evolvesFromSpeciesId,
    this.evolutionMethod,
    this.evolutionItemName,
    this.evolutionItemImageUrl,
    this.types = const [],
  });

  final int id;
  final String name;
  final int? evolvesFromSpeciesId;
  final String? evolutionMethod;
  final String? evolutionItemName;
  final String? evolutionItemImageUrl;
  final List<String> types;

  String get imageUrl => 'assets/offline_catalog/normal/$id.webp';
}
