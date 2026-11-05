import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/screens/app_shell.dart';
import 'package:pokeapp_flutter/ui/screens/widgets/app_bottom_nav.dart';
import 'package:pokeapp_flutter/ui/screens/teams/teams_screen.dart';
import 'package:pokeapp_flutter/ui/theme/theme.dart';

class _Api extends Fake implements PokemonRepository {
  final queries = <String>[];
  @override
  Future<List<PokemonItem>> searchPokemon(String query) async {
    queries.add(query);
    return [
      PokemonItem(id: 25, name: 'pikachu', types: ['electric'])
    ];
  }

  @override
  Future<List<PokemonItem>> getPokemonList(
          {int limit = 20, int offset = 0}) async =>
      limit == 30
          ? [
              PokemonItem(id: 25, name: 'pikachu', types: ['electric'])
            ]
          : [];
}

// Keep widget tests independent of remote artwork availability.
class _Images extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _Client();
}

class _Client extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _Request();
  @override
  set autoUncompress(bool value) {}
}

class _Headers extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _Request extends Fake implements HttpClientRequest {
  @override
  HttpHeaders get headers => _Headers();
  @override
  Future<HttpClientResponse> close() async => _Response();
}

class _Response extends Stream<List<int>> implements HttpClientResponse {
  final bytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Wl6N+0AAAAASUVORK5CYII=');
  @override
  int get statusCode => 200;
  @override
  int get contentLength => bytes.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
          {Function? onError, void Function()? onDone, bool? cancelOnError}) =>
      Stream<List<int>>.value(bytes).listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
      'team creation and nested routes keep navigation visible across tabs',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final previous = HttpOverrides.current;
    HttpOverrides.global = _Images();
    addTearDown(() => HttpOverrides.global = previous);
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = _Api();
    await tester.pumpWidget(MaterialApp(
      theme: buildPokeTheme(),
      localizationsDelegates: const [AppLocalizations.delegate],
      home: AppShell(api: api, favorites: FavoritesStore()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Pokédex'), findsOneWidget);
    await tester.tap(find.text('Teams'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create team'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Champions squad');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(TeamEditorScreen), findsOneWidget);
    expect(find.byType(AppBottomNav), findsOneWidget);
    await tester.tap(find.text('Add Pokémon'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(AppBottomNav), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'pi');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 'pik');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(api.queries, ['pik']);
    expect(find.text('Pikachu'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('Pikachu'), findsOneWidget);
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Teams'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.tap(find.text('Pikachu'));
    await tester.pumpAndSettle();
    expect(find.text('Champions squad'), findsOneWidget);
    expect(find.text('1/6 Pokémon'), findsOneWidget);
    expect(find.text('Defensive balance'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove from team'));
    await tester.pumpAndSettle();
    expect(find.text('0/6 Pokémon'), findsOneWidget);
    await tester.tap(find.text('Teams'));
    await tester.pumpAndSettle();
    expect(find.text('My teams'), findsOneWidget);
    expect(find.text('Champions squad'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
