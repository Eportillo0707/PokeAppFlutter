import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokeapp_flutter/data/local/teams_store.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';

PokemonItem member(int id) =>
    PokemonItem(id: id, name: 'pokemon-$id', types: ['fire']);

void main() {
  setUp(
      () => SharedPreferences.setMockInitialValues({'favorite_pokemon': '[]'}));
  test('multiple teams survive reload and edits remain isolated from favorites',
      () async {
    final store = TeamsStore();
    final a = await store.create(' First ');
    final b = await store.create('Second');
    await store.add(a, member(6));
    await store.add(b, member(25));
    await store.rename(a, 'Renamed');
    final restored = TeamsStore();
    await restored.load();
    expect(restored.items.length, 2);
    expect(restored.find(a)!.name, 'Renamed');
    expect(restored.find(a)!.members.single.id, 6);
    expect(restored.find(b)!.members.single.id, 25);
    await restored.remove(a, 6);
    await restored.delete(a);
    final latest = TeamsStore();
    await latest.load();
    expect(latest.items.single.id, b);
    expect(
        (await SharedPreferences.getInstance()).getString('favorite_pokemon'),
        '[]');
  });
  test('concurrent writes enforce six slots and do not lose members', () async {
    final store = TeamsStore();
    final id = await store.create('Six');
    await Future.wait([for (var i = 1; i <= 6; i++) store.add(id, member(i))]);
    expect(store.find(id)!.members.length, 6);
    await expectLater(store.add(id, member(7)), throwsStateError);
    await store.remove(id, 1);
    await expectLater(store.add(id, member(2)), throwsStateError);
    await store.add(id, member(7));
    final restored = TeamsStore();
    await restored.load();
    expect(restored.find(id)!.members.map((p) => p.id), [2, 3, 4, 5, 6, 7]);
  });
  test('invalid names and unreadable saved data are not overwritten', () async {
    final store = TeamsStore();
    await expectLater(store.create('  '), throwsArgumentError);
    SharedPreferences.setMockInitialValues({TeamsStore.storageKey: 'invalid'});
    final broken = TeamsStore();
    await expectLater(broken.load(), throwsFormatException);
    await expectLater(broken.create('New'), throwsFormatException);
    expect(
        (await SharedPreferences.getInstance())
            .getString(TeamsStore.storageKey),
        'invalid');
  });
}
