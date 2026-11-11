import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/artwork_network_image.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_header.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/normalized_pokemon_artwork.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';

void main() {
  testWidgets('shiny artwork is selected immediately', (tester) async {
    const normal = 'assets/offline_catalog/normal/6.webp';
    const shiny = 'assets/offline_catalog/shiny/6.webp';
    Widget artwork(String selected) => MaterialApp(home: Scaffold(body:
        NormalizedPokemonArtwork(normalUrl: normal, imageUrl: selected,
            size: 200)));
    await tester.pumpWidget(artwork(normal));
    await tester.pumpWidget(artwork(shiny));
    expect(tester.widget<ArtworkNetworkImage>(
        find.byType(ArtworkNetworkImage)).url, shiny);
  });

  testWidgets('shiny action remains tappable over the artwork', (tester) async {
    final pokemon = PokemonInfo(id: 6, name: 'charizard', height: 17,
        weight: 905, baseExperience: 267, stats: const [],
        types: const ['fire', 'flying'], evolutionChain: const [],
        megaEvolutions: const [], regionalForms: const [],
        gigantamaxForms: const [], abilities: const [], description: '',
        cryUrl: 'offline_catalog/cries/6.ogg',
        shinyImageUrl: 'assets/offline_catalog/shiny/6.webp');
    var taps = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SizedBox(
        width: 360, child: DetailHeader(pokemon: pokemon, showShiny: false,
            onBack: () {}, onFavorite: () {}, onPlayCry: () {},
            onShinyToggle: () => taps++)))));
    await tester.tap(find.byIcon(Icons.auto_awesome));
    expect(taps, 1);
  });
}
