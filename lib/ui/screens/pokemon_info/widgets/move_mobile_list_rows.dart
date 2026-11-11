part of 'move_mobile_list.dart';

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

