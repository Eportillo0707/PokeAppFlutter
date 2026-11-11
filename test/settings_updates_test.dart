import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/screens/settings/settings_screen.dart';

void main() {
  testWidgets('shows local catalog version without update configuration',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(
      localizationsDelegates: [AppLocalizations.delegate],
      home: SettingsScreen(updates: null),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('2026.11.05'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });
}
