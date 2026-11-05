import 'app_localizations.dart';
import '../utils/pokemon_formatters.dart';

extension MoveLocalizations on AppLocalizations {
  String get moves => isSpanish ? 'Movimientos' : 'Moves';
  String get game => isSpanish ? 'Juego' : 'Game';
  String get filterMoves => isSpanish ? 'Filtrar' : 'Filter';
  String get learningHeading => isSpanish ? 'Aprendizaje' : 'Learning';
  String get tapLearningHint => isSpanish
      ? 'Toca un movimiento para ver qué hace.'
      : 'Tap a move to see what it does.';
  String get learnMethod =>
      isSpanish ? 'Método de aprendizaje' : 'Learn method';
  String get allMethods => isSpanish ? 'Todos los métodos' : 'All methods';
  String get searchMoves =>
      isSpanish ? 'Buscar movimiento (nombre en inglés)' : 'Search moves';
  String get noMoves =>
      isSpanish ? 'No hay movimientos disponibles.' : 'No moves available.';
  String get noMatchingMoves => isSpanish
      ? 'No hay movimientos para estos filtros.'
      : 'No moves match these filters.';

  String methodName(String method) {
    return switch (method) {
      'level-up' => isSpanish ? 'Por nivel' : 'Level up',
      'machine' => isSpanish ? 'Por máquina' : 'By machine',
      'train' => 'Train',
      'egg' => isSpanish ? 'Huevo' : 'Egg',
      'tutor' => isSpanish ? 'Tutor' : 'Tutor',
      'light-ball-egg' =>
        isSpanish ? 'Huevo con Bolaluminosa' : 'Light Ball egg',
      'stadium-surfing-pikachu' =>
        isSpanish ? 'Pikachu Surf de Stadium' : 'Stadium surfing Pikachu',
      'form-change' => isSpanish ? 'Cambio de forma' : 'Form change',
      'zygarde-cube' => isSpanish ? 'Arca de Zygarde' : 'Zygarde Cube',
      _ => formatPokemonName(method),
    };
  }

  String learningLabel(String method, int level) {
    if (method != 'level-up') return methodName(method);
    if (level == 0) {
      return isSpanish
          ? 'Por nivel · Sin nivel indicado'
          : 'Level up · Level unspecified';
    }
    return isSpanish ? 'Nivel $level' : 'Level $level';
  }

  String machineLabel(String item) {
    final match = RegExp(r'^(tm|hm|tr)(\d+)$').firstMatch(item);
    if (match == null) return methodName('machine');
    final (code, name) = switch (match[1]) {
      'tm' =>
        isSpanish ? ('MT', 'Máquina Técnica') : ('TM', 'Technical Machine'),
      'hm' => isSpanish ? ('MO', 'Máquina Oculta') : ('HM', 'Hidden Machine'),
      'tr' => isSpanish ? ('DT', 'Disco Técnico') : ('TR', 'Technical Record'),
      _ => ('', ''),
    };
    return '$code${match[2]} · $name';
  }

  String machineCode(String item) => machineLabel(item).split(' · ').first;

  String shortLearningLabel(String method, int level) {
    if (method == 'level-up' && level == 0) {
      return isSpanish ? 'Nivel no especificado' : 'Level unspecified';
    }
    if (method == 'light-ball-egg') {
      return isSpanish ? 'Huevo especial' : 'Special egg';
    }
    if (method == 'stadium-surfing-pikachu') return 'Stadium';
    if (method == 'zygarde-cube') return isSpanish ? 'Arca' : 'Cube';
    return learningLabel(method, level);
  }

  String learningExplanation(String method, int level) => switch (method) {
        'level-up' => level == 0
            ? (isSpanish
                ? 'Se aprende por nivel; no se especifica un nivel concreto en este juego.'
                : 'Learned by leveling up; no specific level is provided for this game.')
            : (isSpanish
                ? 'Se aprende al alcanzar el nivel $level en este juego.'
                : 'Learned upon reaching level $level in this game.'),
        'machine' => isSpanish
            ? 'Se enseña con una máquina. No hay información sobre el objeto concreto para este juego.'
            : 'Taught using a machine. The specific item is not available for this game.',
        'egg' => isSpanish
            ? 'Movimiento que puede heredarse mediante la crianza en este juego.'
            : 'A move that can be inherited through breeding in this game.',
        'tutor' => isSpanish
            ? 'Un tutor de movimientos puede enseñarlo en este juego.'
            : 'A move tutor can teach it in this game.',
        _ => methodName(method),
      };

  String gameName(String name) {
    if (!isSpanish) return formatPokemonName(name);
    return _spanishGames[name] ?? formatPokemonName(name);
  }
}

const _spanishGames = {
  'red-blue': 'Rojo / Azul',
  'yellow': 'Amarillo',
  'gold-silver': 'Oro / Plata',
  'crystal': 'Cristal',
  'ruby-sapphire': 'Rubí / Zafiro',
  'emerald': 'Esmeralda',
  'firered-leafgreen': 'Rojo Fuego / Verde Hoja',
  'diamond-pearl': 'Diamante / Perla',
  'platinum': 'Platino',
  'heartgold-soulsilver': 'HeartGold / SoulSilver',
  'black-white': 'Negro / Blanco',
  'black-2-white-2': 'Negro 2 / Blanco 2',
  'x-y': 'X / Y',
  'omega-ruby-alpha-sapphire': 'Rubí Omega / Zafiro Alfa',
  'sun-moon': 'Sol / Luna',
  'ultra-sun-ultra-moon': 'Ultrasol / Ultraluna',
  'lets-go-pikachu-lets-go-eevee': 'Let’s Go Pikachu / Eevee',
  'sword-shield': 'Espada / Escudo',
  'brilliant-diamond-shining-pearl': 'Diamante Brillante / Perla Reluciente',
  'legends-arceus': 'Leyendas: Arceus',
  'scarlet-violet': 'Escarlata / Púrpura',
};
