part of 'move_mobile_list.dart';

extension _MoveGameControl on _MoveMobileListState {
  Widget _gamePicker(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          key: const ValueKey('move-game-picker'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          leading: Icon(Icons.sports_esports_outlined,
              size: 22, color: Theme.of(context).colorScheme.primary),
          title: Text(l10n.isSpanish ? 'Juego seleccionado' : 'Selected game',
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
            final game =
                await showMoveGamePicker(context, widget.games, widget.game);
            if (game != null && mounted && game != widget.game) {
              widget.onGame(game);
            }
          },
        ),
      ),
    );
  }
}
