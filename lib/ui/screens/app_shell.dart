import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'package:pokeapp_flutter/ui/screens/favorites_screen.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/pokemon_list_screen.dart';
import 'package:pokeapp_flutter/ui/screens/widgets/app_bottom_nav.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.api,
    required this.favorites,
  });

  final PokemonRepository api;
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
      HeroMode(
        enabled: index == 0,
        child: PokemonListScreen(api: widget.api, favorites: widget.favorites),
      ),
      HeroMode(
        enabled: index == 1,
        child: FavoritesScreen(api: widget.api, favorites: widget.favorites),
      ),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: AppBottomNav(
        index: index,
        onSelected: (next) => setState(() => index = next),
      ),
    );
  }
}
