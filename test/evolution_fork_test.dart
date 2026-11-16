import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_fork.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_item.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_routes.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_section.dart';

const ralts = [
  PokemonSpecies(id: 280, name: 'ralts'),
  PokemonSpecies(
      id: 281,
      name: 'kirlia',
      evolvesFromSpeciesId: 280,
      evolutionMethod: 'Level 20'),
  PokemonSpecies(
      id: 282,
      name: 'gardevoir',
      evolvesFromSpeciesId: 281,
      evolutionMethod: 'Level 30'),
  PokemonSpecies(
      id: 475,
      name: 'gallade',
      evolvesFromSpeciesId: 281,
      evolutionMethod: 'Use Dawn Stone on Male'),
];

void main() {
  test('fork shares only the common trunk', () {
    final fork = EvolutionFork.fromRoutes(evolutionRoutes(ralts))!;
    expect(fork.shared.map((item) => item.name), ['ralts', 'kirlia']);
    expect(fork.branches.map((item) => item.name), ['gardevoir', 'gallade']);
    expect(
        EvolutionFork.fromRoutes(evolutionRoutes([
          const PokemonSpecies(id: 1, name: 'root'),
          const PokemonSpecies(id: 2, name: 'a', evolvesFromSpeciesId: 1),
          const PokemonSpecies(id: 3, name: 'b', evolvesFromSpeciesId: 1),
          const PokemonSpecies(id: 4, name: 'c', evolvesFromSpeciesId: 3),
        ])),
        isNull);
  });

  testWidgets('Ralts and Kirlia appear once beside stacked branches',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: EvolutionSection(
                    title: 'Evolution Chain',
                    species: ralts,
                    showArrows: true,
                    currentPokemonId: 280,
                    onSpeciesTap: (_) {})))));
    await tester.pumpAndSettle();
    for (final name in ['Ralts', 'Kirlia', 'Gardevoir', 'Gallade']) {
      expect(find.text(name), findsOneWidget);
    }
    final cards = find.byType(EvolutionItem);
    expect(cards, findsNWidgets(4));
    expect(tester.getSize(cards.at(0)).height,
        greaterThan(tester.getSize(cards.at(2)).height));
    expect(tester.getCenter(find.text('Gardevoir')).dy,
        lessThan(tester.getCenter(find.text('Gallade')).dy));
    expect(tester.takeException(), isNull);
  });
}
