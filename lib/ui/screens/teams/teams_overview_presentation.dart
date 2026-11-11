part of 'teams_screen.dart';

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
                  if (teams.isEmpty) return _emptyTeams(context, es);
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
