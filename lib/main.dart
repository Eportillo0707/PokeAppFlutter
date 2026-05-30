import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/di/app_dependencies.dart';
import 'package:pokeapp_flutter/ui/screens/app_shell.dart';
import 'package:pokeapp_flutter/ui/theme/theme.dart';

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
  late final AppDependencies dependencies;
  bool showSplash = true;

  @override
  void initState() {
    super.initState();
    dependencies = AppDependencies();
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
          : AppShell(
              api: dependencies.pokemonRepository,
              favorites: dependencies.favoritesStore,
            ),
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
