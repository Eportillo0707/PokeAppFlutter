import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';

class PokemonMapper {
  PokemonItem mapPokemonItem(Map<String, dynamic> detail) {
    final types = _sortedTypes(detail);
    return PokemonItem(
      id: detail['id'] as int,
      name: detail['name'] as String,
      types: types.map((slot) => slot['type']['name'] as String).toList(),
    );
  }

  PokemonInfo mapPokemonInfo({
    required Map<String, dynamic> pokemon,
    required Map<String, dynamic>? species,
    required Map<String, dynamic>? evolutionChain,
    required List<Map<String, dynamic>> abilities,
    required List<PokemonSpecies> megaEvolutions,
    String languageCode = 'en',
  }) {
    final evolutions = [
      ...mapEvolutionSpecies(evolutionChain, languageCode: languageCode),
      ...megaEvolutions,
    ];

    return PokemonInfo(
      id: pokemon['id'] as int,
      name: pokemon['name'] as String,
      height: pokemon['height'] as int? ?? 0,
      weight: pokemon['weight'] as int? ?? 0,
      baseExperience: pokemon['base_experience'] as int? ?? 0,
      stats: _mapStats(pokemon),
      types: _sortedTypes(pokemon)
          .map((slot) => slot['type']['name'] as String)
          .toList(),
      evolutionChain: distinctSpecies(evolutions),
      megaEvolutions: megaEvolutions,
      abilities: _mapAbilities(pokemon, abilities, languageCode),
      description: _localizedFlavor(
        species?['flavor_text_entries'],
        languageCode,
      ),
    );
  }

  List<PokemonSpecies> mapEvolutionSpecies(
    Map<String, dynamic>? chain, {
    String languageCode = 'en',
  }) {
    if (chain == null) return [];
    return _flattenEvolutionChain(
      chain['chain'] as Map<String, dynamic>,
      languageCode: languageCode,
    );
  }

  List<PokemonSpecies> distinctSpecies(List<PokemonSpecies> species) {
    final byName = <String, PokemonSpecies>{};
    for (final item in species) {
      byName[item.name] = item;
    }
    return byName.values.toList()..sort((a, b) => a.id.compareTo(b.id));
  }

  List<Map<String, dynamic>> _sortedTypes(Map<String, dynamic> pokemon) {
    return List<Map<String, dynamic>>.from(pokemon['types'] as List)
      ..sort((a, b) => (a['slot'] as int).compareTo(b['slot'] as int));
  }

  List<PokemonStat> _mapStats(Map<String, dynamic> pokemon) {
    return List<Map<String, dynamic>>.from(pokemon['stats'] as List)
        .map(
          (slot) => PokemonStat(
            name: slot['stat']['name'] as String,
            baseStat: slot['base_stat'] as int,
          ),
        )
        .toList();
  }

  List<PokemonAbility> _mapAbilities(
    Map<String, dynamic> pokemon,
    List<Map<String, dynamic>> abilities,
    String languageCode,
  ) {
    return List<Map<String, dynamic>>.from(pokemon['abilities'] as List)
        .map((slot) {
      final name = slot['ability']['name'] as String;
      final ability =
          abilities.where((item) => item['name'] == name).firstOrNull;
      return PokemonAbility(
        name: _localizedName(
          ability?['names'],
          languageCode,
          fallback: name,
        ),
        flavorText: _localizedAbilityText(
          ability,
          languageCode,
        ),
      );
    }).toList();
  }

  List<PokemonSpecies> _flattenEvolutionChain(
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
      evolutionMethod: _formatEvolutionMethod(detail, languageCode),
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
        (child) => _flattenEvolutionChain(
          child,
          evolvesFromSpeciesId: currentId,
          languageCode: languageCode,
        ),
      ),
    ];
  }

  String _localizedFlavor(dynamic entries, String languageCode) {
    if (entries is! List) return '';
    final safeLanguage = languageCode == 'es' ? 'es' : 'en';
    final match = entries
            .cast<Map<String, dynamic>>()
            .where(
              (entry) => entry['language']?['name'] == safeLanguage,
            )
            .firstOrNull ??
        entries
            .cast<Map<String, dynamic>>()
            .where((entry) => entry['language']?['name'] == 'en')
            .firstOrNull;
    return cleanFlavorText(match?['flavor_text'] as String? ?? '');
  }

  String _localizedAbilityText(
    Map<String, dynamic>? ability,
    String languageCode,
  ) {
    if (ability == null) return '';
    final flavor = _localizedFlavor(
      ability['flavor_text_entries'],
      languageCode,
    );
    if (flavor.isNotEmpty) return flavor;
    return _localizedEffect(ability['effect_entries'], languageCode);
  }

  String _localizedEffect(dynamic entries, String languageCode) {
    if (entries is! List) return '';
    final safeLanguage = languageCode == 'es' ? 'es' : 'en';
    final match = entries
            .cast<Map<String, dynamic>>()
            .where((entry) => entry['language']?['name'] == safeLanguage)
            .firstOrNull ??
        entries
            .cast<Map<String, dynamic>>()
            .where((entry) => entry['language']?['name'] == 'en')
            .firstOrNull;
    return cleanFlavorText(
      (match?['short_effect'] as String?) ??
          (match?['effect'] as String?) ??
          '',
    );
  }

  String _localizedName(
    dynamic names,
    String languageCode, {
    required String fallback,
  }) {
    if (names is! List) return formatPokemonName(fallback);
    final safeLanguage = languageCode == 'es' ? 'es' : 'en';
    final match = names
            .cast<Map<String, dynamic>>()
            .where((entry) => entry['language']?['name'] == safeLanguage)
            .firstOrNull ??
        names
            .cast<Map<String, dynamic>>()
            .where((entry) => entry['language']?['name'] == 'en')
            .firstOrNull;
    return match?['name'] as String? ?? formatPokemonName(fallback);
  }

  String? _formatEvolutionMethod(
    Map<String, dynamic>? detail,
    String languageCode,
  ) {
    final spanish = languageCode == 'es';
    if (detail == null) return null;
    if (detail['min_level'] != null) {
      return spanish
          ? 'Nv. ${detail['min_level']}'
          : 'Lvl ${detail['min_level']}';
    }
    if (detail['item'] != null) {
      return formatPokemonName(detail['item']['name']);
    }
    if (detail['min_happiness'] != null) {
      return spanish ? 'Amistad alta' : 'High friendship';
    }
    if (detail['min_beauty'] != null) {
      return spanish
          ? 'Belleza ${detail['min_beauty']}'
          : 'Beauty ${detail['min_beauty']}';
    }
    if (detail['min_affection'] != null) {
      return spanish ? 'Afecto alto' : 'High affection';
    }
    if (detail['held_item'] != null) {
      final item = formatPokemonName(detail['held_item']['name']);
      return spanish ? 'Sostener $item' : 'Hold $item';
    }
    if (detail['known_move'] != null) {
      final move = formatPokemonName(detail['known_move']['name']);
      return spanish ? 'Saber $move' : 'Know $move';
    }
    if (detail['known_move_type'] != null) {
      final type = formatPokemonName(detail['known_move_type']['name']);
      return spanish ? 'Saber movimiento $type' : 'Know $type move';
    }
    if (detail['location'] != null) {
      final location = formatPokemonName(detail['location']['name']);
      return spanish ? 'En $location' : 'At $location';
    }
    if (detail['needs_overworld_rain'] == true) {
      return spanish ? 'Durante lluvia' : 'During rain';
    }
    if (detail['turn_upside_down'] == true) {
      return spanish ? 'Voltear consola' : 'Turn upside down';
    }
    final trigger = detail['trigger']?['name'] as String?;
    if (trigger == 'trade') return spanish ? 'Intercambio' : 'Trade';
    if (trigger == 'level-up') return spanish ? 'Subir nivel' : 'Level up';
    if (trigger == 'use-item') return spanish ? 'Usar objeto' : 'Use item';
    if (trigger == 'shed') {
      return spanish ? 'Evolucion especial' : 'Special evolution';
    }
    return trigger == null ? null : formatPokemonName(trigger);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
