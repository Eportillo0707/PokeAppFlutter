import 'app_localizations.dart';
import 'move_localizations.dart';
import '../utils/pokemon_formatters.dart';

extension MoveLocalizationsExtra on AppLocalizations {
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
