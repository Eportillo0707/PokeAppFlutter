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
  bool showSplash = true;

  @override
  void initState() {
    super.initState();
    api = PokeApiClient();
    favorites = FavoritesStore();
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeAPP',
      debugShowCheckedModeBanner: false,
      theme: buildPokeTheme(),
      home: showSplash
          ? const SplashScreen()
          : AppShell(api: api, favorites: favorites),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121422),
      body: Center(
        child: Image(
          image: AssetImage('assets/splash/bulbasaur_seeklogo.png'),
          width: 170,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
