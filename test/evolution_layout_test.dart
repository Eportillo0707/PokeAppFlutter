import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_section.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/scroll_reveal.dart';

void main() {
  const line = [
    PokemonSpecies(id: 1, name: 'bulbasaur'),
    PokemonSpecies(
        id: 2,
        name: 'ivysaur',
        evolvesFromSpeciesId: 1,
        evolutionMethod: 'Level 16'),
    PokemonSpecies(
        id: 3,
        name: 'venusaur',
        evolvesFromSpeciesId: 2,
        evolutionMethod: 'Level 32'),
  ];

  testWidgets('three stages fit without a horizontal list and image returns',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
      builder: (context) => EvolutionSection(
        title: 'Evolution Chain',
        species: line,
        showArrows: true,
        currentPokemonId: 1,
        onSpeciesTap: (species) => Navigator.of(context).push(
          MaterialPageRoute<void>(
              builder: (_) => Scaffold(
                      body: Hero(
                    tag: 'pokemon-image-${species.name}',
                    child:
                        Image.asset(species.imageUrl, width: 220, height: 220),
                  ))),
        ),
      ),
    ))));
    await tester.pumpAndSettle();
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('Ivysaur'), findsOneWidget);
    expect(find.text('Venusaur'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(find.byType(Hero), findsNWidgets(2));
    expect(find.byType(ScrollReveal), findsOneWidget);
    await tester.tap(find.text('Ivysaur'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(find.text('Ivysaur'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
