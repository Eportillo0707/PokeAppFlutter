part of 'teams_screen.dart';

extension _TeamNameDialogPresentation on _TeamNameDialogState {
  Widget _buildNameDialog(BuildContext context) {
    final es = context.l10n.isSpanish;
    return AlertDialog(
      title: Text(es ? 'Nombre del equipo' : 'Team name'),
      content: Form(
          key: form,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLength: 40,
            validator: (value) => value == null || value.trim().isEmpty
                ? (es ? 'Escribe un nombre' : 'Enter a name')
                : null,
            onFieldSubmitted: (_) => submit(),
          )),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(es ? 'Cancelar' : 'Cancel')),
        FilledButton(onPressed: submit, child: Text(es ? 'Guardar' : 'Save')),
      ],
    );
  }
}

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

extension _TeamsOverviewPresentation on _TeamsScreenState {
  Widget _buildOverview(BuildContext context) {
    final es = context.l10n.isSpanish;
    return Scaffold(
      appBar: AppBar(
          title: Text(es ? 'Mis equipos' : 'My teams',
              style: const TextStyle(fontWeight: FontWeight.w800))),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: create,
          icon: const Icon(Icons.add),
          label: Text(es ? 'Crear equipo' : 'Create team')),
      body: FutureBuilder<void>(
          future: loading,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child: TextButton(
                      onPressed: _reload, child: Text(context.l10n.retry)));
            }
            return AnimatedBuilder(
                animation: widget.store,
                builder: (context, _) {
                  final teams = widget.store.items;
                  if (teams.isEmpty) {
                    return Center(
                        child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.groups_outlined,
                                      size: 64,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  const SizedBox(height: 16),
                                  Text(
                                      es
                                          ? 'Tu próximo equipo empieza aquí'
                                          : 'Your next team starts here',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge),
                                  const SizedBox(height: 12),
                                  Text(
                                      es
                                          ? 'Crea varios equipos, elige hasta 6 Pokémon y revisa sus debilidades.'
                                          : 'Create multiple teams, choose up to 6 Pokémon and review their weaknesses.',
                                      textAlign: TextAlign.center),
                                ])));
                  }
                  return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                      itemCount: teams.length,
                      itemBuilder: (context, index) {
                        final team = teams[index];
                        return Card(
                            color: const Color(0xFF202339),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                  color: Colors.white.withValues(alpha: .12)),
                            ),
                            child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => open(team.id),
                                child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Expanded(
                                                child: Text(team.name,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800))),
                                            Text('${team.members.length}/6'),
                                            const Icon(Icons.chevron_right)
                                          ]),
                                          const SizedBox(height: 12),
                                          Wrap(spacing: 4, children: [
                                            for (final p in team.members)
                                              Tooltip(
                                                  message:
                                                      formatPokemonName(p.name),
                                                  child: TeamPokemonImage(
                                                      pokemon: p)),
                                            if (team.members.isEmpty)
                                              Text(es
                                                  ? 'Añade tu primer Pokémon'
                                                  : 'Add your first Pokémon')
                                          ]),
                                        ]))));
                      });
                });
          }),
    );
  }
}
