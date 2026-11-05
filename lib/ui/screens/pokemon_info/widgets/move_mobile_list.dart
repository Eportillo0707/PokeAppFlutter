import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_move.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/l10n/move_localizations.dart';
import 'move_pill.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';
import 'move_category_badge.dart';
import 'move_description_sheet.dart';
import 'move_game_picker.dart';
part 'move_mobile_list_presentation.dart';

class MoveMobileList extends StatefulWidget {
  const MoveMobileList(
      {super.key,
      required this.moves,
      this.pokemonId,
      required this.game,
      required this.games,
      required this.onGame,
      this.loadMachines,
      this.loadDescription,
      this.loadBattleInfo});
  final List<PokemonMove> moves;
  final int? pokemonId;
  final String game;
  final List<String> games;
  final ValueChanged<String> onGame;
  final MoveMachineLoader? loadMachines;
  final MoveDescriptionLoader? loadDescription;
  final MoveBattleLoader? loadBattleInfo;
  @override
  State<MoveMobileList> createState() => _MoveMobileListState();
}

class _MoveMobileListState extends State<MoveMobileList> {
  void _updateState(VoidCallback change) => setState(change);
  final _details = <String, MoveBattleInfo>{};
  final _machines = <String, List<String>>{};
  final _failed = <String>{};
  late List<PokemonMove> _moves;
  String _method = 'level-up';
  String _type = '';
  String _category = '';
  bool _filters = false;
  int _pending = 0;
  int _limit = 30;
  String? _language;
  PageStorageBucket? _bucket;
  late Set<String> _methods;

  @override
  void initState() {
    super.initState();
    _moves = widget.moves
        .where((m) => m.learning.any((e) => e.game == widget.game))
        .toList();
    final availableMethods = _moves
        .expand((m) => m.learning)
        .where((e) => e.game == widget.game)
        .map((e) => e.method)
        .toSet();
    _methods = widget.game == 'champions'
        ? {'train'}
        : {
            for (final method in ['level-up', 'machine', 'train'])
              if (availableMethods.contains(method)) method,
            ...availableMethods,
          };
    if (_methods.isNotEmpty) _method = _methods.first;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bucket = PageStorage.maybeOf(context);
    if (_language == null) {
      final saved = _bucket?.readState(context,
          identifier: ('move-filters', widget.pokemonId, widget.game));
      if (saved is ({
        String method,
        String type,
        String category,
        bool expanded,
        int limit
      })) {
        if (_methods.contains(saved.method)) _method = saved.method;
        _type = saved.type;
        _category = saved.category;
        _filters = saved.expanded;
        _limit = saved.limit;
      }
      _language = context.l10n.languageCode;
      _fetch(_moves);
    }
  }

  @override
  void deactivate() {
    _bucket?.writeState(context, (
      method: _method,
      type: _type,
      category: _category,
      expanded: _filters,
      limit: _limit
    ), identifier: (
      'move-filters',
      widget.pokemonId,
      widget.game
    ));
    super.deactivate();
  }

  void _finishFetch() => setState(() => _pending--);

  @override
  Widget build(BuildContext context) => _buildMoves(context);
}
