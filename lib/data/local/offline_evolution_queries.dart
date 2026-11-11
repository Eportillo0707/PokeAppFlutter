import 'dart:convert';

import 'package:pokeapp_flutter/data/local/offline_catalog_database.dart';
import 'package:pokeapp_flutter/data/remote/mappers/evolution_method_formatter.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';

part 'offline_normal_evolutions.dart';
part 'offline_evolution_order.dart';

class OfflineEvolutionQueries {
  OfflineEvolutionQueries(this.catalog);
  final OfflineCatalogDatabase catalog;
  static const _formatter = EvolutionMethodFormatter();

  Future<OfflineEvolutions> forChain(int chainId, String language) async {
    final normal = await _normal(chainId, language);
    final forms = await catalog.query(
        'SELECT p.id, p.name, p.species_id, '
        '(SELECT GROUP_CONCAT(t.name) FROM pokemon_types pt '
        'JOIN types t ON t.id = pt.type_id '
        'WHERE pt.pokemon_id = p.id) AS types '
        'FROM pokemon p JOIN species s ON s.id = p.species_id '
        'WHERE s.evolution_chain_id = ? AND p.is_default = 0 '
        'ORDER BY p.id',
        [chainId]);
    final mega = <PokemonSpecies>[];
    final regional = <PokemonSpecies>[];
    final gigantamax = <PokemonSpecies>[];
    for (final row in forms) {
      final name = row['name'] as String;
      String? method;
      List<PokemonSpecies>? group;
      if (name.contains('-mega')) {
        method = language == 'es' ? 'Megaevolución' : 'Mega Evolution';
        group = mega;
      } else if (name.contains('-gmax')) {
        method = language == 'es' ? 'Gigamax' : 'Gigantamax';
        group = gigantamax;
      } else {
        final region = {
          'alola': 'Alola',
          'galar': 'Galar',
          'hisui': 'Hisui',
          'paldea': 'Paldea'
        }
            .entries
            .where((entry) => name.contains('-${entry.key}'))
            .map((entry) => entry.value)
            .firstOrNull;
        if (region != null) {
          method = language == 'es' ? 'Forma $region' : '$region Form';
          group = regional;
        }
      }
      if (group != null) {
        group.add(PokemonSpecies(
            id: row['id'] as int,
            name: name,
            evolvesFromSpeciesId: row['species_id'] as int,
            evolutionMethod: method,
            types: (row['types'] as String? ?? '')
                .split(',')
                .where((type) => type.isNotEmpty)
                .toList()));
      }
    }
    return OfflineEvolutions([...normal, ...mega], mega, regional, gigantamax);
  }
}

class OfflineEvolutions {
  const OfflineEvolutions(
      this.chain, this.mega, this.regional, this.gigantamax);
  final List<PokemonSpecies> chain;
  final List<PokemonSpecies> mega;
  final List<PokemonSpecies> regional;
  final List<PokemonSpecies> gigantamax;
}
