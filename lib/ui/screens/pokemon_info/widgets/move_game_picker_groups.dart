part of 'move_game_picker.dart';

extension _GamePickerGroups on _GamePickerState {
  Map<String, List<String>> _groups(BuildContext context) {
    final l10n = context.l10n;
    final matches = widget.games
        .where((g) =>
            l10n
                .gameName(g)
                .toLowerCase()
                .contains(query.toLowerCase().trim()) ||
            g.contains(query.toLowerCase().trim()))
        .toSet();
    final groups = <String, List<String>>{};
    if (matches.contains('champions')) groups['Champions'] = ['champions'];
    for (var i = _GamePickerState.generations.length - 1; i >= 0; i--) {
      final entries =
          _GamePickerState.generations[i].where(matches.contains).toList();
      if (entries.isNotEmpty) {
        groups['${l10n.isSpanish ? 'Generación' : 'Generation'} ${i + 1}'] =
            entries;
      }
    }
    final known = {
      ..._GamePickerState.generations.expand((g) => g),
      'champions'
    };
    final other = matches.difference(known).toList();
    if (other.isNotEmpty) {
      groups[l10n.isSpanish ? 'Otros juegos' : 'Other games'] = other;
    }
    return groups;
  }
}
