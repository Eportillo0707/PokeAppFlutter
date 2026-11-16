import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_item.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_section.dart';

void main() {
  testWidgets('many branches show their shared parent once', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const species = [
      PokemonSpecies(id: 133, name: 'eevee'),
      PokemonSpecies(
          id: 134,
          name: 'vaporeon',
          evolvesFromSpeciesId: 133,
          evolutionMethod: 'Water Stone'),
      PokemonSpecies(
          id: 135,
          name: 'jolteon',
          evolvesFromSpeciesId: 133,
          evolutionMethod: 'Thunder Stone'),
      PokemonSpecies(
          id: 136,
          name: 'flareon',
          evolvesFromSpeciesId: 133,
          evolutionMethod: 'Fire Stone'),
      PokemonSpecies(
          id: 196,
          name: 'espeon',
          evolvesFromSpeciesId: 133,
          evolutionMethod: 'Friendship during day'),
    ];
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: EvolutionSection(
                    title: 'Evolution Chain',
                    species: species,
                    showArrows: true,
                    currentPokemonId: 133,
                    onSpeciesTap: (_) {})))));
    await tester.pumpAndSettle();
    expect(find.text('Eevee'), findsOneWidget);
    expect(find.byType(EvolutionItem), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });
}
