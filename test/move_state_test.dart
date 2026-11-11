import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_move.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_moves.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/move_pill.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/move_category_badge.dart';

void main() {
  testWidgets(
      'filters and game survive leaving moves and stay isolated per Pokemon',
      (tester) async {
    var visible = true;
    var pokemon = 6;
    late StateSetter update;
    final bucket = PageStorageBucket();
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [AppLocalizations.delegate],
      home: StatefulBuilder(builder: (context, setState) {
        update = setState;
        return Scaffold(
            body: PageStorage(
                bucket: bucket,
                child: SingleChildScrollView(
                  child: visible
                      ? PokemonMovesPage(
                          key: ValueKey(pokemon),
                          pokemonId: pokemon,
                          moves: const [
                            PokemonMove(name: 'ember', learning: [
                              MoveLearning(
                                  game: 'yellow',
                                  gameId: 2,
                                  method: 'level-up',
                                  level: 10),
                              MoveLearning(
                                  game: 'red-blue',
                                  gameId: 1,
                                  method: 'level-up',
                                  level: 9),
                            ])
                          ],
                          loadBattleInfo: (_, __, ___) async =>
                              const MoveBattleInfo(
                                  name: 'Ember',
                                  type: 'fire',
                                  category: 'special',
                                  power: 40,
                                  accuracy: 100),
                        )
                      : const Text('Stats'),
                )));
      }),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Filter'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('move-game-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Red Blue').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Filter'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('type-')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fire').last);
    await tester.pumpAndSettle();
    update(() => visible = false);
    await tester.pumpAndSettle();
    update(() => visible = true);
    await tester.pumpAndSettle();
    expect(find.text('Pokémon Red Blue'), findsOneWidget);
    expect(find.byKey(const ValueKey('type-fire')), findsOneWidget);
    expect(find.text('Ember'), findsOneWidget);
    update(() => pokemon = 25);
    await tester.pumpAndSettle();
    expect(find.text('Pokémon Yellow'), findsOneWidget);
    expect(find.byKey(const ValueKey('type-fire')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('type and category badges share compact size and typography',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        localizationsDelegates: [AppLocalizations.delegate],
        home: Scaffold(
            body: Row(children: [
          MoveTypeBadge(type: 'flying'),
          MoveCategoryBadge(category: 'physical')
        ]))));
    await tester.pumpAndSettle();
    final pills = find.byType(MovePill);
    expect(tester.getSize(pills.first), tester.getSize(pills.last));
    expect(tester.getSize(pills.first).width, 128);
    expect(tester.widget<Text>(find.text('Flying')).style!.fontSize, 11.5);
    expect(tester.widget<Text>(find.text('Physical')).style!.fontSize, 11.5);
  });
}
