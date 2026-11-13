import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:pokeapp_flutter/di/app_dependencies.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
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
  late Future<AppDependencies> dependencies;

  @override
  void initState() {
    super.initState();
    dependencies = AppDependencies.create();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeAPP',
      debugShowCheckedModeBanner: false,
      theme: buildPokeTheme(),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: FutureBuilder<AppDependencies>(
        future: dependencies,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: TextButton(
                onPressed: () => setState(() {
                  dependencies = AppDependencies.create();
                }),
                child: const Text('Could not open local catalog. Retry'),
              )),
            );
          }
          if (!snapshot.hasData) return const SplashScreen();
          final ready = snapshot.data!;
          return AppShell(
            api: ready.pokemonRepository,
            favorites: ready.favoritesStore,
          );
        },
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
          image: AssetImage('assets/icons/app_icon.png'),
          width: 170,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
