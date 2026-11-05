import 'pokemon_models.dart';

class PokemonTeam {
  PokemonTeam(
      {required this.id,
      required this.name,
      List<PokemonItem> members = const []})
      : members = List.unmodifiable(members);
  final String id;
  final String name;
  final List<PokemonItem> members;

  PokemonTeam copyWith({String? name, List<PokemonItem>? members}) =>
      PokemonTeam(
          id: id, name: name ?? this.name, members: members ?? this.members);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'members': members.map((p) => p.toJson()).toList(),
      };
  factory PokemonTeam.fromJson(Map<String, dynamic> json) => PokemonTeam(
        id: json['id'] as String,
        name: json['name'] as String,
        members: (json['members'] as List)
            .map((p) =>
                PokemonItem.fromJson(Map<String, dynamic>.from(p as Map)))
            .toList(),
      );
}
