import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/screens/favorites_screen.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/pokemon_list_screen.dart';

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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 60,
          color: const Color(0xFF232B4C),
          child: Row(
            children: [
              _BottomTab(
                title: context.l10n.pokemon,
                selected: index == 0,
                onTap: () => setState(() => index = 0),
              ),
              _BottomTab(
                title: context.l10n.favorites,
                selected: index == 1,
                onTap: () => setState(() => index = 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomTab extends StatelessWidget {
  const _BottomTab({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 35,
              height: 7,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFE8D8FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
