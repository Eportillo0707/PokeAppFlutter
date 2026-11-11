import 'package:pokeapp_flutter/data/local/offline_catalog_database.dart';
import 'package:pokeapp_flutter/data/local/offline_evolution_queries.dart';
import 'package:pokeapp_flutter/data/local/offline_learnset_queries.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';

class OfflinePokemonDetails {
  OfflinePokemonDetails(this.catalog)
      : _evolutions = OfflineEvolutionQueries(catalog),
        _learnsets = OfflineLearnsetQueries(catalog);
  final OfflineCatalogDatabase catalog;
  final OfflineEvolutionQueries _evolutions;
  final OfflineLearnsetQueries _learnsets;

  Future<PokemonInfo> load(String name, String language) async {
    final rows = await catalog.query('SELECT p.*, s.evolution_chain_id '
        'FROM pokemon p JOIN species s ON s.id = p.species_id '
        'WHERE p.name = ? OR CAST(p.id AS TEXT) = ? LIMIT 1',
        [name.toLowerCase(), name]);
    if (rows.isEmpty) throw StateError('Pokémon not found: $name');
    final pokemon = rows.first;
    final id = pokemon['id'] as int;
    final stats = await catalog.query('SELECT name, base_stat FROM pokemon_stats '
        'WHERE pokemon_id = ? ORDER BY CASE name '
        "WHEN 'hp' THEN 0 WHEN 'attack' THEN 1 WHEN 'defense' THEN 2 "
        "WHEN 'special-attack' THEN 3 WHEN 'special-defense' THEN 4 "
        "WHEN 'speed' THEN 5 ELSE 6 END", [id]);
    final types = await catalog.query('SELECT t.name FROM pokemon_types pt '
        'JOIN types t ON t.id = pt.type_id WHERE pt.pokemon_id = ? '
        'ORDER BY pt.slot', [id]);
    final abilities = await catalog.query('SELECT a.name, '
        'COALESCE(t.description, en.description, \'\') AS description '
        'FROM pokemon_abilities pa JOIN abilities a ON a.id = pa.ability_id '
        'LEFT JOIN ability_text t ON t.ability_id = a.id AND t.language = ? '
        'LEFT JOIN ability_text en ON en.ability_id = a.id AND en.language = \'en\' '
        'WHERE pa.pokemon_id = ? ORDER BY pa.slot', [language, id]);
    final text = await catalog.query('SELECT description FROM species_text '
        'WHERE species_id = ? AND language IN (?, \'en\') '
        'ORDER BY CASE WHEN language = ? THEN 0 ELSE 1 END LIMIT 1',
        [pokemon['species_id'], language, language]);
    final evolutions = await _evolutions.forChain(
        pokemon['evolution_chain_id'] as int, language);
    return PokemonInfo(
      id: id,
      name: pokemon['name'] as String,
      height: pokemon['height'] as int? ?? 0,
      weight: pokemon['weight'] as int? ?? 0,
      baseExperience: pokemon['base_experience'] as int? ?? 0,
      stats: [for (final row in stats) PokemonStat(
          name: row['name'] as String, baseStat: row['base_stat'] as int)],
      types: [for (final row in types) row['name'] as String],
      evolutionChain: evolutions.chain,
      megaEvolutions: evolutions.mega,
      regionalForms: evolutions.regional,
      gigantamaxForms: evolutions.gigantamax,
      abilities: [for (final row in abilities) PokemonAbility(
          name: row['name'] as String, flavorText: row['description'] as String)],
      description: text.isEmpty ? '' : text.first['description'] as String,
      cryUrl: pokemon['cry_asset'] == null ? null :
          'offline_catalog/cries/$id.${catalog.mp3CryIds.contains(id) ? 'mp3' : 'ogg'}',
      shinyImageUrl: 'assets/offline_catalog/shiny/$id.webp',
      moves: await _learnsets.forPokemon(id),
    );
  }
}
