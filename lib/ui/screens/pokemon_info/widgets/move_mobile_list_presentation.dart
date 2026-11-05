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
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  key: const ValueKey('move-game-picker'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  leading: Icon(Icons.sports_esports_outlined,
                      size: 22, color: Theme.of(context).colorScheme.primary),
                  title: Text(
                      l10n.isSpanish ? 'Juego seleccionado' : 'Selected game',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12)),
                  subtitle: Text('Pokémon ${l10n.gameName(widget.game)}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700)),
                  trailing: Icon(Icons.expand_more,
                      color: Theme.of(context).colorScheme.primary),
                  onTap: () async {
                    final game = await showMoveGamePicker(
                        context, widget.games, widget.game);
                    if (game != null && mounted && game != widget.game) {
                      widget.onGame(game);
                    }
                  },
                ),
              ),
            ),
            Theme(
                data: Theme.of(context),
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(18)),
                    child: Column(children: [
                      Row(children: [
                        Expanded(
                            child: Wrap(spacing: 8, runSpacing: 6, children: [
                          for (final method in methods)
                            ChoiceChip(
                              selected: _method == method,
                              showCheckmark: false,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              selectedColor:
                                  Theme.of(context).colorScheme.primary,
                              labelStyle: TextStyle(
                                  color: _method == method
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface),
                              label: Text(method == 'machine'
                                  ? (l10n.isSpanish ? 'MT' : 'TM')
                                  : l10n.methodName(method)),
                              onSelected: (_) => _updateState(() {
                                _method = method;
                                _limit = 30;
                              }),
                            ),
                        ])),
                        IconButton(
                            tooltip: l10n.filterMoves,
                            isSelected: _filters,
                            onPressed: () =>
                                _updateState(() => _filters = !_filters),
                            icon: const Icon(Icons.filter_list)),
                      ]),
                      if (_filters) ...[
                        const SizedBox(height: 16),
                        LayoutBuilder(builder: (context, constraints) {
                          final typeField = DropdownButtonFormField<String>(
                              key: ValueKey('type-$_type'),
                              menuMaxHeight: 260,
                              borderRadius: BorderRadius.circular(16),
                              initialValue: _type,
                              isExpanded: true,
                              decoration: InputDecoration(
                                  labelText: l10n.isSpanish ? 'Tipo' : 'Type'),
                              items: [
                                DropdownMenuItem(
                                    value: '',
                                    child:
                                        Text(l10n.isSpanish ? 'Todos' : 'All')),
                                ...availableTypes.map((t) => DropdownMenuItem(
                                    value: t, child: MoveTypeBadge(type: t)))
                              ],
                              onChanged: (value) => _updateState(() {
                                    _type = value ?? '';
                                    _limit = 30;
                                  }));
                          final categoryField = DropdownButtonFormField<String>(
                              key: ValueKey('category-$_category'),
                              menuMaxHeight: 240,
                              borderRadius: BorderRadius.circular(16),
                              initialValue: _category,
                              isExpanded: true,
                              decoration: InputDecoration(
                                  labelText: l10n.isSpanish
                                      ? 'Categoría'
                                      : 'Category'),
                              items: [
                                DropdownMenuItem(
                                    value: '',
                                    child:
                                        Text(l10n.isSpanish ? 'Todas' : 'All')),
                                ...['physical', 'special', 'status']
                                    .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Row(children: [
                                          MoveCategoryIcon(category: c),
                                          const SizedBox(width: 6),
                                          Flexible(
                                              child: Text(
                                                  moveCategoryName(context, c)))
                                        ])))
                              ],
                              onChanged: (value) => _updateState(() {
                                    _category = value ?? '';
                                    _limit = 30;
                                  }));
                          if (constraints.maxWidth < 300 ||
                              MediaQuery.textScalerOf(context).scale(14) > 20) {
                            return Column(children: [
                              typeField,
                              const SizedBox(height: 12),
                              categoryField
                            ]);
                          }
                          return Row(children: [
                            Expanded(child: typeField),
                            const SizedBox(width: 12),
                            Expanded(child: categoryField)
                          ]);
                        }),
                        TextButton(
                            onPressed: () => _updateState(() {
                                  _type = '';
                                  _category = '';
                                  _limit = 30;
                                }),
                            child: Text(l10n.isSpanish
                                ? 'Limpiar filtros'
                                : 'Clear filters')),
                      ],
                    ]))),
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
            for (final row in rows.take(_limit))
              _moveRow(context, row.$1, row.$2),
            if (rows.length > _limit)
              TextButton(
                  onPressed: () => _updateState(() => _limit += 30),
                  child: Text(l10n.isSpanish ? 'Mostrar más' : 'Show more')),
          ],
        ));
  }
}

extension _MoveMobileListRows on _MoveMobileListState {
  Widget _moveRow(
      BuildContext context, PokemonMove move, List<MoveLearning> learning) {
    final l10n = context.l10n;
    final info = _details[move.name];
    final method = _method == 'machine'
        ? (_machines[move.name]?.isNotEmpty == true
            ? _machines[move.name]!.map(l10n.machineCode).join(' / ')
            : (l10n.isSpanish ? 'MT/MO/DT' : 'TM/HM/TR'))
        : _method == 'level-up'
            ? learning
                .map((e) => e.level == 0
                    ? (l10n.isSpanish ? 'Evol.' : 'Evol.')
                    : '${e.level}')
                .join(' / ')
            : l10n.methodName(_method);
    void open() => showMoveDescription(
        context, move.name, widget.game, widget.loadDescription,
        info: info, loadBattleInfo: widget.loadBattleInfo);
    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: open,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Colors.white.withValues(alpha: .08)))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              width: 64,
                              child: Tooltip(
                                  message: method,
                                  child: Text(method,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary)))),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(
                                  info?.name ?? formatPokemonName(move.name),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700))),
                          const SizedBox(width: 6),
                          _metric(
                              l10n.isSpanish ? 'Pot.' : 'Power',
                              info?.power == null || info?.power == 0
                                  ? '—'
                                  : '${info!.power}'),
                          const SizedBox(width: 8),
                          _metric(
                              l10n.isSpanish ? 'Prec.' : 'Acc.',
                              info?.accuracy == null
                                  ? '—'
                                  : '${info!.accuracy}%'),
                        ]),
                    const SizedBox(height: 12),
                    if (info != null)
                      Wrap(spacing: 8, runSpacing: 6, children: [
                        MoveTypeBadge(type: info.type),
                        MoveCategoryBadge(category: info.category),
                      ])
                    else
                      Text(
                          _failed.contains(move.name)
                              ? l10n.loadError
                              : (l10n.isSpanish
                                  ? 'Cargando datos…'
                                  : 'Loading details…'),
                          style: Theme.of(context).textTheme.bodySmall),
                  ]),
            )));
  }
}

extension _MoveMobileListMetrics on _MoveMobileListState {
  Widget _metric(String label, String value) => SizedBox(
      width: 48,
      child: Column(children: [
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10)),
        const SizedBox(height: 3),
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))
      ]));
}
