import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_move.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/l10n/move_localizations.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';
import 'move_pill.dart';
import 'move_category_badge.dart';
import 'detail_card.dart';
part 'move_description_presentation.dart';

void showMoveDescription(
    BuildContext context, String move, String game, MoveDescriptionLoader? load,
    {MoveBattleInfo? info, MoveBattleLoader? loadBattleInfo}) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (_) => Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context)
              .textTheme
              .apply(bodyColor: Colors.white, displayColor: Colors.white),
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.white)),
        ),
        child: _MoveDescriptionSheet(
            move: move,
            game: game,
            load: load,
            info: info,
            loadBattleInfo: loadBattleInfo)),
  );
}

class _MoveDescriptionSheet extends StatefulWidget {
  const _MoveDescriptionSheet(
      {required this.move,
      required this.game,
      this.load,
      this.info,
      this.loadBattleInfo});
  final String move;
  final String game;
  final MoveDescriptionLoader? load;
  final MoveBattleInfo? info;
  final MoveBattleLoader? loadBattleInfo;
  @override
  State<_MoveDescriptionSheet> createState() => _MoveDescriptionSheetState();
}

class _MoveDescriptionSheetState extends State<_MoveDescriptionSheet> {
  void _updateState(VoidCallback change) => setState(change);
  Future<MoveDescription?>? _future;
  String? _language;
  Future<MoveBattleInfo?>? _battle;

  Future<MoveDescription?> _load() =>
      widget.load?.call(widget.move, widget.game, context.l10n.languageCode) ??
      Future.value();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_language != context.l10n.languageCode) {
      _language = context.l10n.languageCode;
      _future = _load();
      _battle = widget.info != null
          ? Future.value(widget.info)
          : widget.loadBattleInfo?.call(widget.move, widget.game, _language!) ??
              Future.value();
    }
  }

  @override
  Widget build(BuildContext context) => _buildDescription(context);
}
