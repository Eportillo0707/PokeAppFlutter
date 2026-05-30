import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon_models.dart';
import '../utils/pokemon_formatters.dart';

class PokeApiClient {
  PokeApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://pokeapi.co/api/v2';
  final http.Client _client;

  Future<List<PokemonItem>> getPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _getJson('/pokemon?limit=$limit&offset=$offset');
    final results = List<Map<String, dynamic>>.from(data['results'] as List);
    final items = await Future.wait(
      results.map((item) => getPokemonItem(item['name'] as String)),
    );
    items.sort((a, b) => a.id.compareTo(b.id));
    return items;
  }

  Future<List<PokemonItem>> searchPokemon(String query) async {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return [];
    try {
      return [await getPokemonItem(trimmed)];
    } catch (_) {
      final data = await _getJson('/pokemon?limit=1302&offset=0');
      final results = List<Map<String, dynamic>>.from(data['results'] as List);
      final matches = results
          .where((item) => (item['name'] as String).contains(trimmed))
          .take(40)
          .toList();
      return Future.wait(matches.map((item) => getPokemonItem(item['name'])));
    }
  }

  Future<List<PokemonItem>> getPokemonByType(String type) async {
    final data = await _getJson('/type/${type.toLowerCase()}');
    final pokemon = List<Map<String, dynamic>>.from(data['pokemon'] as List);
    final items = await Future.wait(
      pokemon.map((slot) => getPokemonItem(slot['pokemon']['name'] as String)),
    );
    items.sort((a, b) => a.id.compareTo(b.id));
    return items;
  }

  Future<PokemonItem> getPokemonItem(String name) async {
    final detail = await _getJson('/pokemon/${name.toLowerCase()}');
    return _mapPokemonItem(detail);
  }

  Future<PokemonInfo> getPokemonInfo(String name) async {
    final pokemon = await _getJson('/pokemon/${name.toLowerCase()}');
    Map<String, dynamic>? species;
    Map<String, dynamic>? evolutionChain;

    try {
      species = await _getJson('/pokemon-species/${pokemon['species']['name']}');
    } catch (_) {
      species = null;
    }

    try {
      final url = species?['evolution_chain']?['url'] as String?;
      if (url != null) {
        evolutionChain = await _getAbsoluteJson(url);
      }
    } catch (_) {
      evolutionChain = null;
    }

    final normalEvolutions = _mapEvolutionSpecies(evolutionChain);
    final megaEvolutions = await _getMegaEvolutions(normalEvolutions);
    final abilityDtos = await Future.wait(
      List<Map<String, dynamic>>.from(pokemon['abilities'] as List).map(
        (slot) async {
          try {
            return await _getJson('/ability/${slot['ability']['name']}');
          } catch (_) {
            return null;
          }
        },
      ),
    );

    return _mapPokemonInfo(
      pokemon: pokemon,
      species: species,
      evolutionChain: evolutionChain,
      abilities: abilityDtos.whereType<Map<String, dynamic>>().toList(),
      megaEvolutions: megaEvolutions,
    );
  }

  PokemonItem _mapPokemonItem(Map<String, dynamic> detail) {
    final types = List<Map<String, dynamic>>.from(detail['types'] as List)
      ..sort((a, b) => (a['slot'] as int).compareTo(b['slot'] as int));
    return PokemonItem(
      id: detail['id'] as int,
      name: detail['name'] as String,
      types: types.map((slot) => slot['type']['name'] as String).toList(),
    );
  }

  PokemonInfo _mapPokemonInfo({
    required Map<String, dynamic> pokemon,
    required Map<String, dynamic>? species,
    required Map<String, dynamic>? evolutionChain,
    required List<Map<String, dynamic>> abilities,
    required List<PokemonSpecies> megaEvolutions,
  }) {
    final stats = List<Map<String, dynamic>>.from(pokemon['stats'] as List)
        .map(
          (slot) => PokemonStat(
            name: slot['stat']['name'] as String,
            baseStat: slot['base_stat'] as int,
          ),
        )
        .toList();
    final types = List<Map<String, dynamic>>.from(pokemon['types'] as List)
      ..sort((a, b) => (a['slot'] as int).compareTo(b['slot'] as int));
    final description = _englishFlavor(species?['flavor_text_entries']);
    final mappedAbilities =
        List<Map<String, dynamic>>.from(pokemon['abilities'] as List).map((slot) {
      final name = slot['ability']['name'] as String;
      final ability = abilities.where((item) => item['name'] == name).firstOrNull;
      return PokemonAbility(
        name: name,
        flavorText: _englishFlavor(ability?['flavor_text_entries']),
      );
    }).toList();
    final evolutions = [
      ..._mapEvolutionSpecies(evolutionChain),
      ...megaEvolutions,
    ];

    return PokemonInfo(
      id: pokemon['id'] as int,
      name: pokemon['name'] as String,
      height: pokemon['height'] as int? ?? 0,
      weight: pokemon['weight'] as int? ?? 0,
      baseExperience: pokemon['base_experience'] as int? ?? 0,
      stats: stats,
      types: types.map((slot) => slot['type']['name'] as String).toList(),
      evolutionChain: _distinctSpecies(evolutions),
      megaEvolutions: megaEvolutions,
      abilities: mappedAbilities,
      description: description,
    );
  }

  List<PokemonSpecies> _mapEvolutionSpecies(Map<String, dynamic>? chain) {
    if (chain == null) return [];
    return _flattenEvolutionChain(chain['chain'] as Map<String, dynamic>);
  }

  List<PokemonSpecies> _flattenEvolutionChain(
    Map<String, dynamic> link, {
    int? evolvesFromSpeciesId,
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
      evolutionMethod: _formatEvolutionMethod(detail),
      evolutionItemName: itemName as String?,
      evolutionItemImageUrl: itemName == null
          ? null
          : 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/$itemName.png',
    );
    final children = List<Map<String, dynamic>>.from(link['evolves_to'] as List);
    return [
      current,
      ...children.expand(
        (child) => _flattenEvolutionChain(
          child,
          evolvesFromSpeciesId: currentId,
        ),
      ),
    ];
  }

  Future<List<PokemonSpecies>> _getMegaEvolutions(
    List<PokemonSpecies> baseSpecies,
  ) async {
    final all = <PokemonSpecies>[];
    for (final base in baseSpecies) {
      try {
        final species = await _getJson('/pokemon-species/${base.name}');
        final varieties = List<Map<String, dynamic>>.from(
          species['varieties'] as List? ?? [],
        );
        for (final variety in varieties) {
          final varietyName = variety['pokemon']['name'] as String;
          if (!varietyName.toLowerCase().contains('-mega')) continue;
          final detail = await _getJson('/pokemon/$varietyName');
          all.add(
            PokemonSpecies(
              id: detail['id'] as int,
              name: detail['name'] as String,
              evolvesFromSpeciesId: base.id,
              evolutionMethod: 'Mega Evolution',
            ),
          );
        }
      } catch (_) {}
    }
    all.sort((a, b) => a.id.compareTo(b.id));
    return _distinctSpecies(all);
  }

  String _englishFlavor(dynamic entries) {
    if (entries is! List) return '';
    final match = entries.cast<Map<String, dynamic>>().where(
      (entry) => entry['language']?['name'] == 'en',
    ).firstOrNull;
    return cleanFlavorText(match?['flavor_text'] as String? ?? '');
  }

  String? _formatEvolutionMethod(Map<String, dynamic>? detail) {
    if (detail == null) return null;
    if (detail['min_level'] != null) return 'Lvl ${detail['min_level']}';
    if (detail['item'] != null) return formatPokemonName(detail['item']['name']);
    if (detail['min_happiness'] != null) return 'High friendship';
    if (detail['min_beauty'] != null) return 'Beauty ${detail['min_beauty']}';
    if (detail['min_affection'] != null) return 'High affection';
    if (detail['held_item'] != null) {
      return 'Hold ${formatPokemonName(detail['held_item']['name'])}';
    }
    if (detail['known_move'] != null) {
      return 'Know ${formatPokemonName(detail['known_move']['name'])}';
    }
    if (detail['known_move_type'] != null) {
      return 'Know ${formatPokemonName(detail['known_move_type']['name'])} move';
    }
    if (detail['location'] != null) {
      return 'At ${formatPokemonName(detail['location']['name'])}';
    }
    if (detail['needs_overworld_rain'] == true) return 'During rain';
    if (detail['turn_upside_down'] == true) return 'Turn upside down';
    final trigger = detail['trigger']?['name'] as String?;
    if (trigger == 'trade') return 'Trade';
    if (trigger == 'level-up') return 'Level up';
    if (trigger == 'use-item') return 'Use item';
    if (trigger == 'shed') return 'Special evolution';
    return trigger == null ? null : formatPokemonName(trigger);
  }

  List<PokemonSpecies> _distinctSpecies(List<PokemonSpecies> species) {
    final byName = <String, PokemonSpecies>{};
    for (final item in species) {
      byName[item.name] = item;
    }
    return byName.values.toList()..sort((a, b) => a.id.compareTo(b.id));
  }

  Future<Map<String, dynamic>> _getJson(String path) =>
      _getAbsoluteJson('$_baseUrl$path');

  Future<Map<String, dynamic>> _getAbsoluteJson(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('PokeAPI request failed: ${response.statusCode} $url');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
