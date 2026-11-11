import 'pokemon_move.dart';
import 'pokemon_models_support.dart';
export 'pokemon_models_support.dart';

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

  String get imageUrl => 'assets/offline_catalog/normal/$id.webp';

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
    required this.regionalForms,
    required this.gigantamaxForms,
    required this.abilities,
    required this.description,
    required this.cryUrl,
    required this.shinyImageUrl,
    this.moves = const [],
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
  final List<PokemonSpecies> regionalForms;
  final List<PokemonSpecies> gigantamaxForms;
  final List<PokemonAbility> abilities;
  final String description;
  final String? cryUrl;
  final String? shinyImageUrl;
  final List<PokemonMove> moves;
  bool isFavorite;

  String get imageUrl => 'assets/offline_catalog/normal/$id.webp';

  PokemonItem toItem() => PokemonItem(
        id: id,
        name: name,
        types: types,
        isFavorite: isFavorite,
      );
}
