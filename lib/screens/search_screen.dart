import 'package:flutter/material.dart';

import '../models/pokemon_models.dart';
import '../services/favorites_store.dart';
import '../services/pokeapi_client.dart';
import '../widgets/pokemon_widgets.dart';
import 'pokemon_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.api,
    required this.favorites,
  });

  final PokeApiClient api;
  final FavoritesStore favorites;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  List<PokemonItem> results = [];
  bool loading = false;
  bool searched = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = controller.text.trim();
    if (query.isEmpty) return;
    setState(() {
      loading = true;
      searched = true;
    });
    try {
      final next = await widget.api.searchPokemon(query);
      setState(() => results = next);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _openDetail(PokemonItem pokemon) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PokemonDetailScreen(
          api: widget.api,
          favorites: widget.favorites,
          initialPokemon: pokemon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Pokemon')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBar(
              controller: controller,
              hintText: 'Nombre de Pokemon',
              leading: const Icon(Icons.search),
              trailing: [
                IconButton(
                  tooltip: 'Buscar',
                  onPressed: _search,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
              onSubmitted: (_) => _search(),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: widget.favorites,
              builder: (context, _) {
                if (loading) return const LoadingState();
                if (searched && results.isEmpty) {
                  return const Center(child: Text('Sin resultados'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: .92,
                  ),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final pokemon = results[index]
                      ..isFavorite =
                          widget.favorites.isFavorite(results[index].id);
                    return PokemonCard(
                      pokemon: pokemon,
                      onTap: () => _openDetail(pokemon),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
