import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/mega_evolution_section.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/mega_evolution_group.dart';

void main() {
  testWidgets('Gardevoir and Gallade Mega pairs have separate cards',
      (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const normal = [
      PokemonSpecies(id: 282, name: 'gardevoir'),
      PokemonSpecies(id: 475, name: 'gallade'),
    ];
    const mega = [
      PokemonSpecies(
          id: 10051,
          name: 'gardevoir-mega',
          evolvesFromSpeciesId: 282,
          evolutionMethod: 'Mega Evolution'),
      PokemonSpecies(
          id: 10068,
          name: 'gallade-mega',
          evolvesFromSpeciesId: 475,
          evolutionMethod: 'Mega Evolution'),
    ];
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: MegaEvolutionSection(
                    title: 'Mega Evolutions',
                    normal: normal,
                    mega: mega,
                    currentPokemonId: 282,
                    onSpeciesTap: (_) {})))));
    await tester.pumpAndSettle();
    expect(find.byType(MegaEvolutionGroup), findsNWidgets(2));
    final cards = find.byType(Card);
    expect(cards, findsNWidgets(2));
    final first = tester.getRect(cards.first);
    final second = tester.getRect(cards.last);
    expect(second.top - first.bottom, greaterThanOrEqualTo(12));
    expect(find.text('Gardevoir Mega'), findsOneWidget);
    expect(find.text('Gallade Mega'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
