part of 'move_description_test.dart';

void registerMoveDescriptionWidgetTest() {
  testWidgets('name and machine badge open the attack description on demand',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [AppLocalizations.delegate],
      home: Scaffold(
          body: SingleChildScrollView(
              child: PokemonMovesPage(
        moves: const [
          PokemonMove(name: 'thunderbolt', learning: [
            MoveLearning(
                game: 'yellow', gameId: 2, method: 'level-up', level: 0),
            MoveLearning(
                game: 'yellow', gameId: 2, method: 'machine', level: 0),
          ])
        ],
        loadMachines: (_, __) async => ['tm24'],
        loadDescription: (move, game, language) async {
          calls++;
          expect(move, 'thunderbolt');
          expect(game, 'yellow');
          return const MoveDescription(
              text: 'May paralyze the target.', game: 'yellow', language: 'en');
        },
      ))),
    ));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.text('Evol.'), findsOneWidget);
    await tester.tap(find.text('TM'));
    await tester.pumpAndSettle();
    expect(find.text('TM24'), findsOneWidget);
    await tester.tap(find.text('TM24'));
    await tester.pumpAndSettle();
    expect(find.text('May paralyze the target.'), findsOneWidget);
    expect(find.textContaining('Technical Machine'), findsNothing);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thunderbolt').first);
    await tester.pumpAndSettle();
    expect(find.text('May paralyze the target.'), findsOneWidget);
    expect(calls, 2);
  });
}
