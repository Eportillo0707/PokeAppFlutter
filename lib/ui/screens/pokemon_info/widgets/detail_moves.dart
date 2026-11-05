import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_move.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/l10n/move_localizations.dart';
import 'move_mobile_list.dart';

class PokemonMovesPage extends StatefulWidget {
  const PokemonMovesPage(
      {super.key,
      required this.moves,
      this.pokemonId,
      this.loadMachines,
      this.loadDescription,
      this.loadBattleInfo});
  final List<PokemonMove> moves;
  final int? pokemonId;
  final MoveMachineLoader? loadMachines;
  final MoveDescriptionLoader? loadDescription;
  final MoveBattleLoader? loadBattleInfo;
  @override
  State<PokemonMovesPage> createState() => _PokemonMovesPageState();
}

class _PokemonMovesPageState extends State<PokemonMovesPage> {
  String? _game;
  bool _restored = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_restored) {
      _restored = true;
      _game = PageStorage.maybeOf(context)?.readState(context,
          identifier: ('moves-game', widget.pokemonId)) as String?;
    }
  }

  @override
  Widget build(BuildContext context) {
    final games = <String, int>{};
    for (final move in widget.moves) {
      for (final entry in move.learning) {
        games[entry.game] = entry.gameId;
      }
    }
    double rank(int id) => switch (id) {
          28 => -2,
          29 => -1,
          12 => 6.5,
          13 => 6.6,
          _ => id.toDouble()
        };
    final names = games.keys.toList()
      ..sort((a, b) {
        if (a == 'champions') return -1;
        if (b == 'champions') return 1;
        return rank(games[b]!).compareTo(rank(games[a]!));
      });
    if (names.isEmpty) {
      return Padding(
          padding: const EdgeInsets.all(24), child: Text(context.l10n.noMoves));
    }
    final game = games.containsKey(_game) ? _game! : names.first;
    return MoveMobileList(
      key: ValueKey('$game/${context.l10n.languageCode}'),
      moves: widget.moves,
      pokemonId: widget.pokemonId,
      game: game,
      games: names,
      onGame: (value) => setState(() {
        _game = value;
        PageStorage.maybeOf(context)?.writeState(context, value,
            identifier: ('moves-game', widget.pokemonId));
      }),
      loadMachines: widget.loadMachines,
      loadDescription: widget.loadDescription,
      loadBattleInfo: widget.loadBattleInfo,
    );
  }
}
