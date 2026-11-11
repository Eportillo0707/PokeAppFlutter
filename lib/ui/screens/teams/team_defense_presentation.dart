part of 'team_defense_panel.dart';

extension _TeamDefensePresentation on _TeamDefensePanelState {
  Widget _group(BuildContext context, bool weak) {
    final es = context.l10n.isSpanish;
    final types = defenseMultipliers.keys
        .where((t) => affected(t, weak).isNotEmpty)
        .toList()
      ..sort((a, b) {
        final count =
            affected(b, weak).length.compareTo(affected(a, weak).length);
        return count != 0
            ? count
            : context.l10n
                .pokemonType(a)
                .compareTo(context.l10n.pokemonType(b));
      });
    if (types.isEmpty) {
      return Text(
          es ? 'No hay tipos en este grupo.' : 'No types in this group.');
    }
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 300 &&
              MediaQuery.textScalerOf(context).scale(14) <= 20
          ? 2
          : 1;
      final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Wrap(spacing: 10, runSpacing: 10, children: [
          for (final type in types.take(expanded ? types.length : 4))
            SizedBox(
                width: width,
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    key: ValueKey('defense-$weak-$type'),
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showMembers(context, type, weak),
                    child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TypeBadgeImage(type: type, width: 100),
                              const SizedBox(height: 12),
                              Text(
                                  es
                                      ? '${affected(type, weak).length} de ${members.length} ${weak ? 'vulnerables' : 'protegidos'}'
                                      : '${affected(type, weak).length} of ${members.length} ${weak ? 'vulnerable' : 'protected'}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              if (!weak)
                                Text(_resistanceSummary(context, type),
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              if (weak)
                                LinearProgressIndicator(
                                  value: affected(type, true).length /
                                      members.length,
                                  color: pokemonTypeColor(type),
                                  backgroundColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                            ])),
                  ),
                )),
        ]),
        if (types.length > 4)
          TextButton.icon(
            onPressed: () => _updateState(() => expanded = !expanded),
            icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
            label: Text(expanded
                ? (es ? 'Ver menos' : 'Show less')
                : (es ? 'Ver todos los tipos' : 'Show all types')),
          ),
      ]);
    });
  }

  String _resistanceSummary(BuildContext context, String type) {
    final immune = affected(type, false)
        .where((p) => teamDefenseMultiplier(p, type) == 0)
        .length;
    final resist = affected(type, false).length - immune;
    return context.l10n.isSpanish
        ? '$resist resisten · $immune inmunes'
        : '$resist resist · $immune immune';
  }
}
