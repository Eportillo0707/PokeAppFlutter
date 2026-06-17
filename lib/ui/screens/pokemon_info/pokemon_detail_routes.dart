import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/pokemon_detail_screen.dart';

class PokemonDetailRoutes {
  const PokemonDetailRoutes({
    required this.context,
    required this.api,
    required this.favorites,
  });

  final BuildContext context;
  final PokemonRepository api;
  final FavoritesStore favorites;

  Future<void> openEvolution(PokemonItem pokemon) async {
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PokemonDetailScreen(
          api: api,
          favorites: favorites,
          initialPokemon: pokemon,
        ),
      ),
    );
  }

  void showCryError() {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo reproducir el sonido.')),
    );
  }
}
