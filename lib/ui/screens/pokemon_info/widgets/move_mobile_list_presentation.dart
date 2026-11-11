part of 'move_mobile_list.dart';

extension _MoveMobileListPresentation on _MoveMobileListState {
  Widget _buildMoves(BuildContext context) {
    final l10n = context.l10n;
    final methods = _methods;
    final availableTypes = _details.values
        .map((info) => info.type)
        .toSet()
        .toList()
      ..sort((a, b) => l10n.pokemonType(a).compareTo(l10n.pokemonType(b)));
    if (_type.isNotEmpty && !availableTypes.contains(_type)) {
      availableTypes.add(_type);
    }
    final rows = <(PokemonMove, List<MoveLearning>)>[];
    for (final move in _moves) {
      final learning = move.learning
          .where((e) => e.game == widget.game && e.method == _method)
          .toList()
        ..sort((a, b) => a.level.compareTo(b.level));
      final info = _details[move.name];
      if (learning.isEmpty ||
          (_type.isNotEmpty && info?.type != _type) ||
          (_category.isNotEmpty && info?.category != _category)) {
        continue;
      }
      rows.add((move, learning));
    }
    rows.sort((a, b) {
      if (_method == 'level-up') {
        final byLevel = a.$2.first.level.compareTo(b.$2.first.level);
        if (byLevel != 0) return byLevel;
      }
      return (_details[a.$1.name]?.name ?? a.$1.name)
          .compareTo(_details[b.$1.name]?.name ?? b.$1.name);
    });
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _gamePicker(context),
            _filterControls(context, availableTypes, methods),
            const SizedBox(height: 14),
            Text('${rows.length} ${l10n.moves.toLowerCase()}',
                style: Theme.of(context).textTheme.bodySmall),
            if (_pending > 0) const LinearProgressIndicator(),
            if (_failed.isNotEmpty)
              TextButton.icon(
                  onPressed: _pending > 0
                      ? null
                      : () => _updateState(() {
                            _fetch(_moves
                                .where((m) => _failed.contains(m.name))
                                .toList());
                          }),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry)),
            if (rows.isEmpty && _pending == 0)
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(l10n.noMatchingMoves)),
            for (var start = 0;
                start < rows.length && start < _limit;
                start += 5)
              ScrollReveal(
                key: ValueKey('moves-${widget.game}-$_method-$start'),
                child: Column(
                  children: [
                    for (final row
                        in rows.skip(start).take(5).take(_limit - start))
                      _moveRow(context, row.$1, row.$2),
                  ],
                ),
              ),
            if (rows.length > _limit)
              TextButton(
                  onPressed: () => _updateState(() => _limit += 30),
                  child: Text(l10n.isSpanish ? 'Mostrar más' : 'Show more')),
          ],
        ));
  }
}
