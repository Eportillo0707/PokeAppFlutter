import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_artwork.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_hero_scope.dart';

void main() {
  testWidgets('only selected evolution participates in Hero matching',
      (tester) async {
    for (final selected in <String?>[null, 'charizard', null]) {
      await tester.pumpWidget(MaterialApp(
          home: EvolutionHeroScope(
        selected: selected,
        child: Row(children: [
          for (final entry
              in {4: 'charmander', 5: 'charmeleon', 6: 'charizard'}.entries)
            EvolutionArtwork(
                species: PokemonSpecies(id: entry.key, name: entry.value),
                size: 60,
                hero: true),
        ]),
      )));
      expect(
          find.byType(Hero), selected == null ? findsNothing : findsOneWidget);
      if (selected != null) {
        expect(tester.widget<Hero>(find.byType(Hero)).tag,
            'pokemon-image-charizard');
      }
    }
  });
}
