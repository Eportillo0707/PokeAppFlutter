import 'package:pokeapp_flutter/data/remote/mappers/evolution_method_formatter.dart';
import 'package:pokeapp_flutter/data/remote/mappers/mapper_extensions.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';

class PokemonEvolutionMapper {
  const PokemonEvolutionMapper({
    EvolutionMethodFormatter methodFormatter = const EvolutionMethodFormatter(),
  }) : _methodFormatter = methodFormatter;

  final EvolutionMethodFormatter _methodFormatter;

  List<PokemonSpecies> map(
    Map<String, dynamic>? chain, {
    String languageCode = 'en',
  }) {
    if (chain == null) return [];
    return _flatten(
      chain['chain'] as Map<String, dynamic>,
      languageCode: languageCode,
    );
  }

  List<PokemonSpecies> distinctSpecies(List<PokemonSpecies> species) {
    final byName = <String, PokemonSpecies>{};
    for (final item in species) {
      byName.putIfAbsent(item.name, () => item);
    }
    return byName.values.toList();
  }

  List<PokemonSpecies> _flatten(
    Map<String, dynamic> link, {
    int? evolvesFromSpeciesId,
    String languageCode = 'en',
  }) {
    final species = link['species'] as Map<String, dynamic>;
    final currentId = idFromUrl(species['url'] as String);
    final details = List<Map<String, dynamic>>.from(
      link['evolution_details'] as List? ?? [],
    );
    final detail = details.firstOrNull;
    final itemName = detail?['item']?['name'] ?? detail?['held_item']?['name'];
    final current = PokemonSpecies(
      id: currentId,
      name: species['name'] as String,
      evolvesFromSpeciesId: evolvesFromSpeciesId,
      evolutionMethod: _methodFormatter.format(detail, languageCode),
      evolutionItemName: itemName as String?,
      evolutionItemImageUrl: itemName == null
          ? null
          : 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/$itemName.png',
    );
    final children =
        List<Map<String, dynamic>>.from(link['evolves_to'] as List);
    return [
      current,
      ...children.expand(
        (child) => _flatten(
          child,
          evolvesFromSpeciesId: currentId,
          languageCode: languageCode,
        ),
      ),
    ];
  }
}
