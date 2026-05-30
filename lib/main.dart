import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'services/favorites_store.dart';
import 'services/pokeapi_client.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PokeApp());
}

class PokeApp extends StatefulWidget {
  const PokeApp({super.key});

  @override
  State<PokeApp> createState() => _PokeAppState();
}

class _PokeAppState extends State<PokeApp> {
  late final PokeApiClient api;
  late final FavoritesStore favorites;

  @override
  void initState() {
    super.initState();
    api = PokeApiClient();
    favorites = FavoritesStore();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeAPP',
      debugShowCheckedModeBanner: false,
      theme: buildPokeTheme(),
      home: AppShell(api: api, favorites: favorites),
    );
  }
}
