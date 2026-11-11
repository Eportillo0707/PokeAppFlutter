part of 'team_defense_panel.dart';

extension _TeamDefenseMembers on _TeamDefensePanelState {
  void _showMembers(BuildContext context, String type, bool weak) {
    final items = affected(type, weak);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TypeBadgeImage(type: type, width: 120),
          const SizedBox(height: 12),
          Text(
              weak
                  ? (context.l10n.isSpanish
                      ? 'Pokémon vulnerables'
                      : 'Vulnerable Pokémon')
                  : (context.l10n.isSpanish
                      ? 'Pokémon que resisten o son inmunes'
                      : 'Resistant or immune Pokémon'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final p in items)
            ListTile(
              leading: TeamPokemonImage(pokemon: p),
              title: Text(formatPokemonName(p.name)),
              subtitle: TeamPokemonTypes(types: p.types),
              trailing: Text(_multiplierLabel(teamDefenseMultiplier(p, type)),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
            ),
        ]),
      )),
    );
  }

  String _multiplierLabel(double value) => switch (value) {
        0 => '×0',
        .25 => '×¼',
        .5 => '×½',
        2 => '×2',
        4 => '×4',
        _ => '×$value',
      };
}
