import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_section.dart';

void main() {
  testWidgets('branches show parent and each method vertically',
      (tester) async {
    const branches = [
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
    ];
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: _BranchFixture(species: branches)))));
    await tester.pumpAndSettle();
    expect(find.text('Eevee'), findsOneWidget);
    expect(find.text('Vaporeon'), findsOneWidget);
    expect(find.text('Jolteon'), findsOneWidget);
    expect(find.text('Flareon'), findsOneWidget);
    expect(find.text('Water Stone'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _BranchFixture extends StatelessWidget {
  const _BranchFixture({required this.species});
  final List<PokemonSpecies> species;

  @override
  Widget build(BuildContext context) => EvolutionSection(
        title: 'Evolution Chain',
        species: species,
        showArrows: true,
        currentPokemonId: 133,
        onSpeciesTap: (_) {},
      );
}
