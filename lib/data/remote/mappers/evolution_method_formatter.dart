import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';

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
    return _spanishEvolutionItems[raw] ?? formatPokemonName(raw);
  }

  static const _spanishEvolutionItems = {
    'sun-stone': 'Piedra Solar',
    'moon-stone': 'Piedra Lunar',
    'fire-stone': 'Piedra Fuego',
    'thunder-stone': 'Piedra Trueno',
    'water-stone': 'Piedra Agua',
    'leaf-stone': 'Piedra Hoja',
    'shiny-stone': 'Piedra Dia',
    'dusk-stone': 'Piedra Noche',
    'dawn-stone': 'Piedra Alba',
    'ice-stone': 'Piedra Hielo',
    'oval-stone': 'Piedra Oval',
    'kings-rock': 'Roca del Rey',
    'metal-coat': 'Revestimiento Metalico',
    'dragon-scale': 'Escama Dragon',
    'upgrade': 'Mejora',
    'dubious-disc': 'Disco Extrano',
    'protector': 'Protector',
    'electirizer': 'Electrizador',
    'magmarizer': 'Magmatizador',
    'reaper-cloth': 'Tela Terrible',
    'razor-claw': 'Garra Afilada',
    'razor-fang': 'Colmillo Agudo',
    'prism-scale': 'Escama Bella',
    'deep-sea-tooth': 'Diente Marino',
    'deep-sea-scale': 'Escama Marina',
    'sachet': 'Saquito Fragante',
    'whipped-dream': 'Dulce de Nata',
    'sweet-apple': 'Manzana Dulce',
    'tart-apple': 'Manzana Acida',
    'cracked-pot': 'Tetera Rota',
    'chipped-pot': 'Tetera Agrietada',
    'galarica-cuff': 'Brazal Galanuez',
    'galarica-wreath': 'Corona Galanuez',
    'black-augurite': 'Augurita Negra',
    'peat-block': 'Bloque de Turba',
    'auspicious-armor': 'Armadura Auspiciosa',
    'malicious-armor': 'Armadura Maldita',
    'scroll-of-darkness': 'Pergamino Oscuro',
    'scroll-of-waters': 'Pergamino Agua',
    'masterpiece-teacup': 'Taza Exquisita',
    'unremarkable-teacup': 'Taza Corriente',
    'syrupy-apple': 'Manzana Melosa',
  };
}
