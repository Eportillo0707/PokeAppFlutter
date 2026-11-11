part of 'offline_evolution_queries.dart';

extension _OfflineNormalEvolutions on OfflineEvolutionQueries {
  Future<List<PokemonSpecies>> _normal(int chainId, String language) async {
    final species = await catalog.query(
        'SELECT s.id, s.name, s.evolves_from_id, '
        'e.details_json, (SELECT GROUP_CONCAT(t.name) FROM pokemon p '
        'JOIN pokemon_types pt ON pt.pokemon_id = p.id '
        'JOIN types t ON t.id = pt.type_id '
        'WHERE p.species_id = s.id AND p.is_default = 1) AS types '
        'FROM species s LEFT JOIN evolution_edges e '
        'ON e.to_species_id = s.id AND e.chain_id = s.evolution_chain_id '
        'WHERE s.evolution_chain_id = ? ORDER BY s.id',
        [chainId]);
    final normal = <PokemonSpecies>[];
    for (final row in species) {
      final details = row['details_json'] == null
          ? const []
          : jsonDecode(row['details_json'] as String) as List<dynamic>;
      final detail = details.isEmpty
          ? null
          : Map<String, dynamic>.from(details.first as Map);
      final item =
          detail?['item'] as String? ?? detail?['held_item'] as String?;
      if (detail != null) {
        for (final key in [
          'item',
          'held_item',
          'known_move',
          'known_move_type',
          'location',
          'trigger'
        ]) {
          final value = detail[key];
          if (value is String) detail[key] = {'name': value};
        }
      }
      normal.add(PokemonSpecies(
        id: row['id'] as int,
        name: row['name'] as String,
        evolvesFromSpeciesId: row['evolves_from_id'] as int?,
        evolutionMethod:
            OfflineEvolutionQueries._formatter.format(detail, language),
        evolutionItemName: item,
        evolutionItemImageUrl:
            item == null ? null : 'assets/offline_catalog/items/$item.webp',
        types: (row['types'] as String? ?? '')
            .split(',')
            .where((type) => type.isNotEmpty)
            .toList(),
      ));
    }
    return orderEvolutionSpecies(normal);
  }
}
