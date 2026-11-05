import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'package:pokeapp_flutter/ui/screens/favorites_screen.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/pokemon_list_screen.dart';
import 'package:pokeapp_flutter/ui/screens/widgets/app_bottom_nav.dart';
import 'package:pokeapp_flutter/data/local/teams_store.dart';
import 'package:pokeapp_flutter/ui/screens/teams/teams_screen.dart';

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
  final teams = TeamsStore();
  final navigators = List.generate(3, (_) => GlobalKey<NavigatorState>());
  final heroes =
      List.generate(3, (_) => MaterialApp.createMaterialHeroController());
  final visited = <int>{0};

  @override
  void dispose() {
    teams.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.favorites.load();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <WidgetBuilder>[
      (_) => PokemonListScreen(api: widget.api, favorites: widget.favorites),
      (_) => FavoritesScreen(api: widget.api, favorites: widget.favorites),
      (_) => TeamsScreen(
          store: teams, api: widget.api, favorites: widget.favorites),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: [
        for (var tab = 0; tab < pages.length; tab++)
          if (!visited.contains(tab))
            const SizedBox.shrink()
          else
            NavigatorPopHandler<Object?>(
              enabled: index == tab,
              onPopWithResult: (_) => navigators[tab].currentState!.maybePop(),
              child: HeroControllerScope(
                controller: heroes[tab],
                child: Navigator(
                  key: navigators[tab],
                  onGenerateRoute: (_) =>
                      MaterialPageRoute<void>(builder: pages[tab]),
                ),
              ),
            ),
      ]),
      bottomNavigationBar: AppBottomNav(
        index: index,
        onSelected: (next) {
          if (index == next) {
            navigators[next].currentState?.popUntil((route) => route.isFirst);
          } else {
            setState(() {
              index = next;
              visited.add(next);
            });
          }
        },
      ),
    );
  }
}
