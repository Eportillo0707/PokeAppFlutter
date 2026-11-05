import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_move.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_moves.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/swipeable_detail_page.dart';

const moves = [
  PokemonMove(name: 'tackle', learning: [
    MoveLearning(game: 'red-blue', gameId: 1, method: 'level-up', level: 1),
  ]),
  PokemonMove(name: 'thunderbolt', learning: [
    MoveLearning(game: 'yellow', gameId: 2, method: 'level-up', level: 26),
    MoveLearning(game: 'yellow', gameId: 2, method: 'machine', level: 0),
    MoveLearning(game: 'yellow', gameId: 2, method: 'tutor', level: 0),
  ]),
];

Widget app(List<PokemonMove> data) => MaterialApp(
      localizationsDelegates: const [AppLocalizations.delegate],
      home: Scaffold(
          body: SingleChildScrollView(child: PokemonMovesPage(moves: data))),
    );

void main() {
  testWidgets('mobile tabs and game selection update the move list',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(moves));
    await tester.pumpAndSettle();
    expect(find.text('Thunderbolt'), findsOneWidget);
    expect(find.text('26'), findsOneWidget);
    expect(find.text('Train'), findsNothing);
    await tester.tap(find.text('Tutor').first);
    await tester.pumpAndSettle();
    expect(find.text('Thunderbolt'), findsOneWidget);
    await tester.tap(find.text('TM'));
    await tester.pumpAndSettle();
    expect(find.text('Thunderbolt'), findsOneWidget);
    expect(find.text('TM/HM/TR'), findsOneWidget);
    expect(find.text('Machine'), findsNothing);
    await tester.tap(find.byTooltip('Filter'));
    await tester.pumpAndSettle();
    expect(find.text('Learn method'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('move-game-picker')));
    await tester.pumpAndSettle();
    expect(find.text('Generation 1'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'no-such-game');
    await tester.pumpAndSettle();
    expect(find.text('No games found.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'red');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Red Blue').last);
    await tester.pumpAndSettle();
    expect(find.text('Tackle'), findsOneWidget);
    expect(find.text('Thunderbolt'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('empty learnsets show an explicit empty state', (tester) async {
    await tester.pumpWidget(app([]));
    await tester.pumpAndSettle();
    expect(find.text('No moves available.'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
  });

  testWidgets('swiping stats opens moves and moves returns to stats',
      (tester) async {
    var selected = 1;
    await tester.pumpWidget(
        MaterialApp(home: StatefulBuilder(builder: (context, setState) {
      return SwipeableDetailPage(
          selectedPage: selected,
          onPageSelected: (value) => setState(() => selected = value),
          child: const SizedBox.expand());
    })));
    await tester.fling(
        find.byType(SwipeableDetailPage), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(selected, 2);
    await tester.fling(
        find.byType(SwipeableDetailPage), const Offset(300, 0), 1000);
    await tester.pumpAndSettle();
    expect(selected, 1);
  });
}
