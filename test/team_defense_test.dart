import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/screens/teams/team_defense_panel.dart';

void main() {
  final dragon = PokemonItem(id: 149, name: 'dragonite', types: ['dragon', 'flying']);
  final ghost = PokemonItem(id: 94, name: 'gengar', types: ['ghost', 'poison']);
  test('dual types combine weaknesses, resistances and immunities', () {
    expect(teamDefenseMultiplier(dragon, 'ice'), 4);
    expect(teamDefenseMultiplier(dragon, 'ground'), 0);
    expect(teamDefenseMultiplier(dragon, 'grass'), .25);
    expect(teamDefenseMultiplier(ghost, 'normal'), 0);
  });
  testWidgets('defense cards open affected members with exact multipliers', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [AppLocalizations.delegate],
      home: Scaffold(body: SingleChildScrollView(child: TeamDefensePanel(members: [dragon, ghost]))),
    ));
    await tester.pumpAndSettle();
    final showAll = find.text('Show all types');
    await tester.ensureVisible(showAll);
    await tester.tap(showAll);
    await tester.pumpAndSettle();
    final ice = find.byKey(const ValueKey('defense-true-ice'));
    await tester.ensureVisible(ice);
    await tester.tap(ice);
    await tester.pumpAndSettle();
    expect(find.text('Dragonite'), findsOneWidget);
    expect(find.text('Gengar'), findsNothing);
    expect(find.text('×4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
