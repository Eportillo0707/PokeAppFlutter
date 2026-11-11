import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/mega_evolution_section.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_item.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_connector.dart';

void main() {
  testWidgets('Charizard stays centered between both mega forms',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const charizard =
        PokemonSpecies(id: 6, name: 'charizard', types: ['fire', 'flying']);
    const forms = [
      PokemonSpecies(
          id: 10034,
          name: 'charizard-mega-x',
          evolvesFromSpeciesId: 6,
          evolutionMethod: 'Charizardite X',
          types: ['fire', 'dragon']),
      PokemonSpecies(
          id: 10035,
          name: 'charizard-mega-y',
          evolvesFromSpeciesId: 6,
          evolutionMethod: 'Charizardite Y',
          types: ['fire', 'flying']),
    ];
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: MegaEvolutionSection(
                title: 'Mega Evolutions',
                normal: [charizard],
                mega: forms,
                currentPokemonId: 6,
                onSpeciesTap: _ignore))));
    await tester.pumpAndSettle();
    final x = tester.getCenter(find.text('Charizard Mega X'));
    final base = tester.getCenter(find.text('Charizard'));
    final y = tester.getCenter(find.text('Charizard Mega Y'));
    expect(x.dx, lessThan(base.dx));
    expect(base.dx, lessThan(y.dx));
    expect((x.dy - y.dy).abs(), lessThan(25));
    final cards = find.byType(EvolutionItem);
    expect(cards, findsNWidgets(3));
    expect(
        tester.getSize(cards.at(0)).height, tester.getSize(cards.at(1)).height);
    final name = tester.widget<Text>(find.text('Charizard Mega X'));
    expect(name.style!.fontSize, lessThanOrEqualTo(14));
    final stones = tester
        .widgetList<EvolutionConnector>(find.byType(EvolutionConnector))
        .map((item) => item.stoneAsset)
        .toList();
    expect(stones, [
      'assets/offline_catalog/items/charizardite-x.png',
      'assets/offline_catalog/items/charizardite-y.png',
    ]);
    for (final stone in stones) {
      expect((await rootBundle.load(stone!)).lengthInBytes, greaterThan(0));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('one Mega form sits beside its base', (tester) async {
    const base =
        PokemonSpecies(id: 3, name: 'venusaur', types: ['grass', 'poison']);
    const form = PokemonSpecies(
        id: 10033,
        name: 'venusaur-mega',
        evolvesFromSpeciesId: 3,
        evolutionMethod: 'Mega Evolution',
        types: ['grass', 'poison']);
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: MegaEvolutionSection(
                title: 'Mega Evolutions',
                normal: [base],
                mega: [form],
                currentPokemonId: 3,
                onSpeciesTap: _ignore))));
    await tester.pumpAndSettle();
    expect(tester.getCenter(find.text('Venusaur')).dx,
        lessThan(tester.getCenter(find.text('Venusaur Mega')).dx));
    expect(find.text('Mega Evolution'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _ignore(PokemonSpecies _) {}
