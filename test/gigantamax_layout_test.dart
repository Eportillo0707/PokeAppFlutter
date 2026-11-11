import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_section.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_item.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_type_icons.dart';

void main() {
  testWidgets('Gigantamax cards fit with names on one line', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const forms = [
      PokemonSpecies(id: 6, name: 'charizard-gmax', types: ['fire', 'flying']),
      PokemonSpecies(id: 3, name: 'venusaur-gmax', types: ['grass', 'poison']),
      PokemonSpecies(id: 9, name: 'blastoise-gmax', types: ['water']),
    ];
    await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!),
        home: Scaffold(
            body: EvolutionSection(
                title: 'Gigantamax',
                species: forms,
                showArrows: false,
                currentPokemonId: 25,
                onSpeciesTap: (_) {}))));
    await tester.pumpAndSettle();
    for (final name in ['Charizard Gmax', 'Venusaur Gmax', 'Blastoise Gmax']) {
      final text = tester.widget<Text>(find.text(name));
      expect(text.maxLines, 1);
      expect(text.softWrap, false);
    }
    final cards = find.byType(EvolutionItem);
    final icons = find.byType(EvolutionTypeIcons);
    for (var index = 0; index < 3; index++) {
      expect(
          tester.getRect(cards.at(index)).bottom -
              tester.getRect(icons.at(index)).bottom,
          lessThanOrEqualTo(10));
    }
    expect(tester.takeException(), isNull);
  });
}
