import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokeapp_flutter/data/remote/move_machine_source.dart';
import 'package:pokeapp_flutter/data/remote/pokeapi_http_client.dart';
import 'package:pokeapp_flutter/data/remote/pokemon_remote_data_source.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_move.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/l10n/move_localizations.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_moves.dart';

void main() {
  test(
      'description prefers selected game and language, preserves fallback source and shares cache',
      () async {
    var calls = 0;
    final source = MoveMachineSource(PokemonRemoteDataSource(
        client: PokeApiHttpClient(client: MockClient((_) async {
      calls++;
      return http.Response(
          jsonEncode({
            'machines': [],
            'flavor_text_entries': [
              {
                'language': {'name': 'es'},
                'version_group': {'name': 'yellow'},
                'flavor_text': 'Puede\nparalizar.'
              },
              {
                'language': {'name': 'es'},
                'version_group': {'name': 'sword-shield'},
                'flavor_text': 'Texto reciente.'
              },
              {
                'language': {'name': 'en'},
                'version_group': {'name': 'yellow'},
                'flavor_text': 'May paralyze.'
              },
            ]
          }),
          200);
    }))));
    final exact = await source.getDescription('thunderbolt', 'yellow', 'es');
    expect(exact!.text, 'Puede paralizar.');
    expect(exact.game, 'yellow');
    final fallback =
        await source.getDescription('thunderbolt', 'unknown', 'es');
    expect(fallback!.game, 'sword-shield');
    expect(fallback.language, 'es');
    final english = await source.getDescription('thunderbolt', 'yellow', 'en');
    expect(english!.text, 'May paralyze.');
    await source.getMachines('thunderbolt', 'yellow');
    expect(calls, 1);
  });

  test('zero level is explicit in both languages', () {
    expect(
        const AppLocalizations(Locale('es')).shortLearningLabel('level-up', 0),
        'Nivel no especificado');
    expect(
        const AppLocalizations(Locale('en')).shortLearningLabel('level-up', 0),
        'Level unspecified');
  });

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
