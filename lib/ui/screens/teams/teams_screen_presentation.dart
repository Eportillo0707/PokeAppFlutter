part of 'teams_screen.dart';

extension _TeamEditorPresentation on _TeamEditorScreenState {
  Widget _buildEditor(BuildContext context) => AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final team = widget.store.find(widget.id);
        final es = context.l10n.isSpanish;
        if (team == null) return const Scaffold();
        return Scaffold(
          appBar: AppBar(
              title: Text(team.name,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              actions: [
                IconButton(
                    tooltip: es ? 'Renombrar' : 'Rename',
                    onPressed: busy ? null : rename,
                    icon: const Icon(Icons.edit_outlined)),
                IconButton(
                    tooltip: es ? 'Eliminar equipo' : 'Delete team',
                    onPressed: busy ? null : delete,
                    icon: const Icon(Icons.delete_outline)),
              ]),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            Text('${team.members.length}/6 Pokémon',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(es
                ? 'Los cambios se guardan en este dispositivo.'
                : 'Changes are saved on this device.'),
            if (busy) const LinearProgressIndicator(),
            const SizedBox(height: 16),
            for (final p in team.members)
              Card(
                  color: const Color(0xFF202339),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side:
                        BorderSide(color: Colors.white.withValues(alpha: .12)),
                  ),
                  child: ListTile(
                    leading: TeamPokemonImage(pokemon: p),
                    title: Text(formatPokemonName(p.name),
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                    subtitle: TeamPokemonTypes(types: p.types),
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => PokemonDetailScreen(
                                api: widget.api,
                                favorites: widget.favorites,
                                initialPokemon: p))),
                    trailing: IconButton(
                        tooltip: es ? 'Quitar del equipo' : 'Remove from team',
                        onPressed: busy
                            ? null
                            : () => save(
                                () => widget.store.remove(widget.id, p.id)),
                        icon: const Icon(Icons.remove_circle_outline)),
                  )),
            if (team.members.length < 6)
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: OutlinedButton.icon(
                      onPressed: busy ? null : add,
                      icon: const Icon(Icons.add),
                      label: Text(es ? 'Añadir Pokémon' : 'Add Pokémon'))),
            if (team.members.isNotEmpty)
              TeamDefensePanel(members: team.members),
          ]),
        );
      });
}
