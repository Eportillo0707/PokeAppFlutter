import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_route_card.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_connector.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_routes.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_section.dart';

const applin = [
  PokemonSpecies(id: 840, name: 'applin'),
  PokemonSpecies(
      id: 841,
      name: 'flapple',
      evolvesFromSpeciesId: 840,
      evolutionMethod: 'Tart Apple'),
  PokemonSpecies(
      id: 842,
      name: 'appletun',
      evolvesFromSpeciesId: 840,
      evolutionMethod: 'Sweet Apple'),
  PokemonSpecies(
      id: 1011,
      name: 'dipplin',
      evolvesFromSpeciesId: 840,
      evolutionMethod: 'Syrupy Apple'),
  PokemonSpecies(
      id: 1019,
      name: 'hydrapple',
      evolvesFromSpeciesId: 1011,
      evolutionMethod: 'Know Dragon Cheer'),
];

void main() {
  test('each branch is a complete root-to-leaf route', () {
    expect(
        evolutionRoutes(applin)
            .map((route) => route.map((item) => item.name).toList())
            .toList(),
        [
          ['applin', 'flapple'],
          ['applin', 'appletun'],
          ['applin', 'dipplin', 'hydrapple'],
        ]);
  });

  testWidgets('shows separate routes and animates only tapped duplicate',
      (tester) async {
    tester.view.physicalSize = const Size(320, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: EvolutionSection(
                    title: 'Evolution Chain',
                    species: applin,
                    showArrows: true,
                    currentPokemonId: 1011,
                    onSpeciesTap: (_) {})))));
    await tester.pumpAndSettle();
    expect(find.byType(EvolutionRouteCard), findsNWidgets(3));
    expect(find.text('Applin'), findsNWidgets(3));
    for (final method in [
      'Tart Apple',
      'Sweet Apple',
      'Syrupy Apple',
      'Know Dragon Cheer'
    ]) {
      expect(find.text(method), findsOneWidget);
    }
    tester.view.physicalSize = const Size(400, 950);
    await tester.pumpAndSettle();
    expect(find.byType(EvolutionConnector), findsNWidgets(4));
    final hero = find.byWidgetPredicate(
        (widget) => widget is Hero && widget.tag == 'pokemon-image-applin');
    expect(hero, findsOneWidget);
    final firstTop = tester.getTopLeft(hero).dy;
    await tester.tap(find.text('Applin').at(1));
    await tester.pumpAndSettle();
    expect(hero, findsOneWidget);
    expect(tester.getTopLeft(hero).dy, greaterThan(firstTop));
    expect(tester.takeException(), isNull);
  });
}
