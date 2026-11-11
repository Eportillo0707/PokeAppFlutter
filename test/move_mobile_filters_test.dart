import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_move.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_moves.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/move_category_badge.dart';

void main() {
  testWidgets(
      'Champions starts on Train and filters only known move types in a bounded menu',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        localizationsDelegates: const [AppLocalizations.delegate],
        home: Scaffold(
            body: SingleChildScrollView(
                child: PokemonMovesPage(
          moves: const [
            PokemonMove(name: 'future-move', learning: [
              MoveLearning(
                  game: 'future-game', gameId: 99, method: 'level-up', level: 1)
            ]),
            PokemonMove(name: 'ember', learning: [
              MoveLearning(
                  game: 'champions', gameId: 32, method: 'train', level: 0)
            ]),
            PokemonMove(name: 'tackle', learning: [
              MoveLearning(
                  game: 'champions', gameId: 32, method: 'train', level: 0)
            ]),
          ],
          loadBattleInfo: (move, game, language) async => MoveBattleInfo(
              name: move == 'ember' ? 'Ember' : 'Tackle',
              type: move == 'ember' ? 'fire' : 'normal',
              category: move == 'ember' ? 'special' : 'physical',
              power: 40,
              accuracy: 100,
              pp: 25),
        )))));
    await tester.pumpAndSettle();
    expect(find.text('Ember'), findsOneWidget);
    expect(find.text('Tackle'), findsOneWidget);
    expect(find.text('Level up'), findsNothing);
    expect(find.text('TM'), findsNothing);
    expect(find.text('Future Move'), findsNothing);
    expect(tester.widget<ChoiceChip>(find.byType(ChoiceChip)).selected, isTrue);
    expect(find.byType(MoveCategoryIcon), findsNWidgets(2));
    await tester.tap(find.byTooltip('Filter'));
    await tester.pumpAndSettle();
    final typeFinder = find.byKey(const ValueKey('type-'));
    final field = tester.widget<DropdownButton<String>>(find.descendant(
        of: typeFinder, matching: find.byType(DropdownButton<String>)));
    expect(field.items!.map((item) => item.value), ['', 'fire', 'normal']);
    expect(field.menuMaxHeight, 260);
    await tester.tap(typeFinder);
    await tester.pumpAndSettle();
    expect(find.text('Water'), findsNothing);
    await tester.tap(find.text('Fire').last);
    await tester.pumpAndSettle();
    expect(find.text('Ember'), findsOneWidget);
    expect(find.text('Tackle'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
