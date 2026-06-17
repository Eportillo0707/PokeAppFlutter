import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_generation.dart';

Future<void> precacheGenerationStarterImages(BuildContext context) {
  final urls = pokemonGenerations
      .expand((generation) => generation.starterIds)
      .map(officialPokemonArtworkUrl);
  return Future.wait(
    urls.map((url) => precacheImage(NetworkImage(url), context)),
  ).then((_) {});
}
