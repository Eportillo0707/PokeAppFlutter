import 'package:pokeapp_flutter/domain/utils/pokemon_name.dart';
import 'spanish_evolution_items.dart';

class EvolutionMethodFormatter {
  const EvolutionMethodFormatter();

  String? format(Map<String, dynamic>? detail, String languageCode) {
    final spanish = languageCode == 'es';
    if (detail == null) return null;
    if (detail['min_level'] != null) {
      return spanish
          ? 'Nv. ${detail['min_level']}'
          : 'Lvl ${detail['min_level']}';
    }
    if (detail['item'] != null) {
      return formatItemName(detail['item']['name'], languageCode);
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
      final item = formatItemName(
        detail['held_item']['name'],
        languageCode,
      );
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

  String formatItemName(dynamic itemName, String languageCode) {
    final raw = itemName as String;
    if (languageCode != 'es') return formatPokemonName(raw);
    return spanishEvolutionItems[raw] ?? formatPokemonName(raw);
  }
}
