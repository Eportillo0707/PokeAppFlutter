part of 'team_pokemon_picker.dart';

extension _TeamPokemonPickerPresentation on _TeamPokemonPickerState {
  Widget _buildPicker(BuildContext context) {
    final es = context.l10n.isSpanish;
    return Scaffold(
      appBar: AppBar(title: Text(es ? 'Añadir Pokémon' : 'Add Pokémon')),
      body: Column(children: [
        Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => search(),
              onChanged: _onQueryChanged,
              decoration: InputDecoration(
                hintText: es
                    ? 'Nombre o número de Pokédex'
                    : 'Name or Pokédex number',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                suffixIcon: IconButton(
                    tooltip: es ? 'Buscar' : 'Search',
                    onPressed: search,
                    icon: const Icon(Icons.search)),
              ),
            )),
        Expanded(
            child: FutureBuilder<List<PokemonItem>>(
          future: results,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child: TextButton(
                      onPressed: search, child: Text(context.l10n.retry)));
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return Center(
                  child: Text(
                      es ? 'No se encontraron Pokémon.' : 'No Pokémon found.'));
            }
            return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final p = items[index];
                  final added = widget.excluded.contains(p.id);
                  return ListTile(
                    leading: TeamPokemonImage(pokemon: p),
                    title: Text(formatPokemonName(p.name),
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                    subtitle: TeamPokemonTypes(types: p.types),
                    trailing: Icon(
                        added ? Icons.check_circle : Icons.add_circle_outline),
                    enabled: !added,
                    onTap: added ? null : () => Navigator.pop(context, p),
                  );
                });
          },
        )),
      ]),
    );
  }
}
