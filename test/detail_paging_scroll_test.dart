import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/data/local/offline_catalog_database.dart';
import 'package:pokeapp_flutter/data/local/offline_pokemon_repository.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_move.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/pokemon_detail_screen.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_tabs.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _Api extends Fake implements PokemonRepository {
  _Api(this.info);
  final PokemonInfo info;
  @override
  Future<PokemonInfo> getPokemonInfo(String name,
          {String languageCode = 'en'}) async =>
      info;
  @override
  Future<MoveBattleInfo> getMoveBattleInfo(
          String move, String game, String language) async =>
      const MoveBattleInfo(
          name: 'Move',
          type: 'fire',
          category: 'special',
          power: 40,
          accuracy: 100);
  @override
  Future<MoveDescription?> getMoveDescription(
          String move, String game, String language) async =>
      null;
  @override
  Future<List<String>> getMoveMachines(String move, String game) async => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late _Api api;
  late PokemonItem item;
  late PokemonInfo info;
  setUpAll(() async {
    final catalog = await OfflineCatalogDatabase.open();
    final repository = OfflinePokemonRepository(catalog);
    item = await repository.getPokemonItem('charizard');
    info = await repository.getPokemonInfo('charizard');
    await catalog.close();
    api = _Api(info);
  });

  testWidgets('switching Info Stats and Moves preserves scroll',
      (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [AppLocalizations.delegate],
      home: PokemonDetailScreen(
          api: api,
          favorites: FavoritesStore(),
          initialPokemon: item,
          preloadedInfo: info,
          preloadedLanguageCode: 'en'),
    ));
    await tester.pumpAndSettle();
    final scroll = tester
        .widget<SingleChildScrollView>(find.byType(SingleChildScrollView).first)
        .controller!;
    scroll.jumpTo(220);
    await tester.pumpAndSettle();
    final tabs = tester.widget<DetailTabs>(find.byType(DetailTabs));
    tabs.onStatsClick();
    await tester.pumpAndSettle();
    expect(scroll.offset, greaterThan(100));
    tester.widget<DetailTabs>(find.byType(DetailTabs)).onMovesClick();
    await tester.pumpAndSettle();
    expect(scroll.offset, greaterThan(100));
    tester.widget<DetailTabs>(find.byType(DetailTabs)).onInfoClick();
    await tester.pumpAndSettle();
    expect(scroll.offset, closeTo(220, 1));
  });
}
