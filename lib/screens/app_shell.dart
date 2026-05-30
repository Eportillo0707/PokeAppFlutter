import 'package:flutter/material.dart';

import '../services/favorites_store.dart';
import '../services/pokeapi_client.dart';
import 'favorites_screen.dart';
import 'pokemon_list_screen.dart';
import 'search_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.api,
    required this.favorites,
  });

  final PokeApiClient api;
  final FavoritesStore favorites;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    widget.favorites.load();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      PokemonListScreen(api: widget.api, favorites: widget.favorites),
      SearchScreen(api: widget.api, favorites: widget.favorites),
      FavoritesScreen(api: widget.api, favorites: widget.favorites),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.catching_pokemon_outlined),
            selectedIcon: Icon(Icons.catching_pokemon),
            label: 'Pokemon',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }
}
