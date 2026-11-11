part of 'move_game_picker.dart';

extension _GamePickerPresentation on _GamePickerState {
  Widget _buildPicker(BuildContext context) {
    final l10n = context.l10n;
    final groups = _groups(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .7,
        child: Column(children: [
          ListTile(
            title: Text(l10n.isSpanish ? 'Elegir juego' : 'Choose game',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            trailing: IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 22),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (value) => _updateState(() => query = value),
              decoration: InputDecoration(
                hintText: l10n.isSpanish ? 'Buscar juego' : 'Search games',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
              child: ListView(children: [
            if (groups.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.isSpanish
                    ? 'No se encontraron juegos.'
                    : 'No games found.'),
              ),
            for (final group in groups.entries)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                child: Material(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  clipBehavior: Clip.antiAlias,
                  child: group.key == 'Champions'
                      ? _gameTile('champions')
                      : ExpansionTile(
                          key: ValueKey((group.key, query.trim().isNotEmpty)),
                          initiallyExpanded: query.trim().isNotEmpty ||
                              group.value.contains(widget.selected),
                          shape: const Border(),
                          collapsedShape: const Border(),
                          title: Text(group.key,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(
                            group.value.contains(widget.selected)
                                ? '${l10n.isSpanish ? 'Seleccionado' : 'Selected'}: ${l10n.gameName(widget.selected)}'
                                : '${group.value.length} ${l10n.isSpanish ? 'juegos disponibles' : 'available games'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          childrenPadding:
                              const EdgeInsets.fromLTRB(8, 0, 8, 8),
                          children: [
                            for (final game in group.value) _gameTile(game),
                          ],
                        ),
                ),
              ),
          ])),
        ]),
      ),
    );
  }
}

extension _GamePickerTiles on _GamePickerState {
  Widget _gameTile(String game) {
    final selected = game == widget.selected;
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: Icon(Icons.sports_esports_outlined,
          size: 20, color: selected ? colors.primary : colors.onSurfaceVariant),
      title: Text(context.l10n.gameName(game)),
      selected: selected,
      selectedColor: colors.primary,
      selectedTileColor: colors.primary.withValues(alpha: .12),
      trailing:
          selected ? const Icon(Icons.check_circle_outline, size: 22) : null,
      onTap: () => Navigator.pop(context, game),
    );
  }
}
