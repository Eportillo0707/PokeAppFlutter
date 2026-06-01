class PokemonItem {
  PokemonItem({
    required this.id,
    required this.name,
    required this.types,
    this.isFavorite = false,
  });

  final int id;
  final String name;
  final List<String> types;
  bool isFavorite;

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'types': types,
      };

  factory PokemonItem.fromJson(Map<String, dynamic> json) => PokemonItem(
        id: json['id'] as int,
        name: json['name'] as String,
        types: List<String>.from(json['types'] as List),
      );
}

class PokemonInfo {
  PokemonInfo({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.baseExperience,
    required this.stats,
    required this.types,
    required this.evolutionChain,
    required this.megaEvolutions,
    required this.abilities,
    required this.description,
    required this.cryUrl,
    this.isFavorite = false,
  });

  final int id;
  final String name;
  final int height;
  final int weight;
  final int baseExperience;
  final List<PokemonStat> stats;
  final List<String> types;
  final List<PokemonSpecies> evolutionChain;
  final List<PokemonSpecies> megaEvolutions;
  final List<PokemonAbility> abilities;
  final String description;
  final String? cryUrl;
  bool isFavorite;

  PokemonItem toItem() => PokemonItem(
        id: id,
        name: name,
        types: types,
        isFavorite: isFavorite,
      );
}

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
  });

  final int id;
  final String name;
  final int? evolvesFromSpeciesId;
  final String? evolutionMethod;
  final String? evolutionItemName;
  final String? evolutionItemImageUrl;

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}
