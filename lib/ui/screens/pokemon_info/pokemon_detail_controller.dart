import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/pokemon_cry_player.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';

class PokemonDetailController {
  PokemonDetailController({
    required this.api,
    required this.favorites,
    required this.initialPokemon,
    this.preloadedInfo,
    this.preloadedLanguageCode,
  });

  final PokemonRepository api;
  final FavoritesStore favorites;
  final PokemonItem initialPokemon;
  final PokemonInfo? preloadedInfo;
  final String? preloadedLanguageCode;
  final cryPlayer = AudioPlayer();
  final shinyPlayer = AudioPlayer();
  Future<void> _shinyPlayback = Future<void>.value();
  final scrollController = ScrollController();

  late Future<PokemonInfo> future;
  String? languageCode;
  int selectedPage = 0;
  bool isPopping = false;
  bool showShiny = false;

  void loadForLanguage(String nextLanguageCode) {
    if (languageCode == nextLanguageCode) return;
    languageCode = nextLanguageCode;
    future = preloadedInfo != null && preloadedLanguageCode == nextLanguageCode
        ? Future.value(preloadedInfo)
        : api.getPokemonInfo(
            initialPokemon.name,
            languageCode: nextLanguageCode,
          );
  }

  void retry(String nextLanguageCode) {
    future = api.getPokemonInfo(
      initialPokemon.name,
      languageCode: nextLanguageCode,
    );
  }

  Future<void> toggleFavorite(PokemonInfo pokemon) async {
    await favorites.toggle(pokemon.toItem());
    pokemon.isFavorite = favorites.isFavorite(pokemon.id);
  }

  Future<void> playCry(PokemonInfo pokemon) async {
    final cryUrl = pokemon.cryUrl;
    if (cryUrl == null || cryUrl.isEmpty) return;
    await playPokemonCry(cryPlayer, cryUrl);
  }

  Future<void> playShinySound() {
    _shinyPlayback = _shinyPlayback.catchError((Object _) {}).then((_) async {
      await shinyPlayer.stop();
      await shinyPlayer.play(AssetSource('sounds/shiny_8.mp3'));
    });
    return _shinyPlayback;
  }

  Future<PokemonItem> getPokemonItem(PokemonSpecies species) {
    return api.getPokemonItem(species.name);
  }

  Future<void> prepareHeroPop(VoidCallback resetShiny) async {
    if (showShiny) {
      showShiny = false;
      resetShiny();
      await Future<void>.delayed(const Duration(milliseconds: 80));
    }
    if (scrollController.hasClients && scrollController.offset > 12) {
      await scrollController.animateTo(0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic);
    }
  }

  void dispose() {
    cryPlayer.dispose();
    shinyPlayer.dispose();
    scrollController.dispose();
  }
}
