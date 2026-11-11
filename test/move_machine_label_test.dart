import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_move.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/l10n/move_localizations.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/move_machine_label.dart';

void main() {
  test('machine names and numbers are localized for both supported languages',
      () {
    const es = AppLocalizations(Locale('es'));
    const en = AppLocalizations(Locale('en'));
    expect(es.machineLabel('tm24'), 'MT24 · Máquina Técnica');
    expect(es.machineLabel('hm03'), 'MO03 · Máquina Oculta');
    expect(es.machineLabel('tr04'), 'DT04 · Disco Técnico');
    expect(en.machineLabel('tm24'), 'TM24 · Technical Machine');
    expect(en.machineLabel('hm03'), 'HM03 · Hidden Machine');
    expect(en.machineLabel('tr04'), 'TR04 · Technical Record');
    expect(es.machineLabel('unknown'), 'Por máquina');
  });

  Widget app(String game, MoveMachineLoader load) => MaterialApp(
        localizationsDelegates: const [AppLocalizations.delegate],
        home: Scaffold(
            body: MoveMachineLabel(move: 'surf', game: game, load: load)),
      );

  testWidgets(
      'late responses from the previous game cannot replace the current machine',
      (tester) async {
    final old = Completer<List<String>>();
    Future<List<String>> load(String move, String game) =>
        game == 'red-blue' ? old.future : Future.value(['tr04']);
    await tester.pumpWidget(app('red-blue', load));
    await tester.pumpAndSettle();
    expect(find.text('Checking machine…'), findsOneWidget);
    await tester.pumpWidget(app('sword-shield', load));
    await tester.pumpAndSettle();
    expect(find.text('TR04'), findsOneWidget);
    old.complete(['hm03']);
    await tester.pumpAndSettle();
    expect(find.text('TR04'), findsOneWidget);
    expect(find.textContaining('HM03'), findsNothing);
  });

  testWidgets(
      'errors offer retry and missing records use generic machine label',
      (tester) async {
    var calls = 0;
    Future<List<String>> load(String move, String game) async {
      if (++calls == 1) throw Exception('offline');
      return [];
    }

    await tester.pumpWidget(app('red-blue', load));
    await tester.pumpAndSettle();
    expect(find.text('By machine · Unverified'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('By machine'), findsOneWidget);
    expect(calls, 2);
  });
}
