import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/main.dart';

void main() {
  testWidgets('PokeAPP renders the main shell', (tester) async {
    await tester.pumpWidget(const PokeApp());
    await tester.pump();

    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Pokemon'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
  });
}
