part of 'move_mobile_list.dart';

extension _MoveMobileListLoading on _MoveMobileListState {
  Future<void> _fetch(List<PokemonMove> moves) async {
    _pending += moves.length;
    await Future.wait(moves.map((move) async {
      try {
        final info = await widget.loadBattleInfo
            ?.call(move.name, widget.game, _language!);
        if (info != null) _details[move.name] = info;
        if (move.learning
            .any((e) => e.game == widget.game && e.method == 'machine')) {
          _machines[move.name] =
              await widget.loadMachines?.call(move.name, widget.game) ?? [];
        }
        _failed.remove(move.name);
      } catch (_) {
        _failed.add(move.name);
      }
      if (mounted) _finishFetch();
    }));
  }
}

