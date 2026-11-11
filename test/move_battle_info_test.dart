import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokeapp_flutter/data/remote/move_machine_source.dart';
import 'package:pokeapp_flutter/data/remote/pokemon_remote_data_source.dart';
import 'package:pokeapp_flutter/data/remote/pokeapi_http_client.dart';

void main() {
  test(
      'rewinds power and accuracy by game order independently and uses pre-split category',
      () async {
    final versions = {'old': (7, 3), 'middle': (15, 5), 'new': (19, 7)};
    final source = MoveMachineSource(PokemonRemoteDataSource(
        client: PokeApiHttpClient(client: MockClient((request) async {
      if (request.url.path.contains('/version-group/')) {
        final name = request.url.pathSegments.where((s) => s.isNotEmpty).last;
        final version = versions[name]!;
        return http.Response(
            jsonEncode({
              'order': version.$1,
              'generation': {
                'url': 'https://pokeapi.co/api/v2/generation/${version.$2}/'
              }
            }),
            200);
      }
      return http.Response(
          jsonEncode({
            'name': 'test-move',
            'power': 40,
            'accuracy': 100,
            'type': {'name': 'fire'},
            'damage_class': {'name': 'physical'},
            'names': [
              {
                'language': {'name': 'es'},
                'name': 'Ataque'
              }
            ],
            'past_values': [
              {
                'version_group': {
                  'url': 'https://pokeapi.co/api/v2/version-group/middle/'
                },
                'power': 35,
                'accuracy': 95
              },
              {
                'version_group': {
                  'url': 'https://pokeapi.co/api/v2/version-group/new/'
                },
                'power': 50,
                'accuracy': null
              },
            ],
          }),
          200);
    }))));
    final old = await source.getBattleInfo('test-move', 'old', 'es');
    expect(old.name, 'Ataque');
    expect(old.power, 35);
    expect(old.accuracy, 95);
    expect(old.category, 'special');
    final middle = await source.getBattleInfo('test-move', 'middle', 'en');
    expect(middle.power, 50);
    expect(middle.accuracy, 100);
    expect(middle.category, 'physical');
    final latest = await source.getBattleInfo('test-move', 'new', 'en');
    expect(latest.power, 40);
  });

  test('status moves retain null power and accuracy', () async {
    final source = MoveMachineSource(PokemonRemoteDataSource(
        client: PokeApiHttpClient(
            client: MockClient((request) async => http.Response(
                jsonEncode(
                  request.url.path.contains('/version-group/')
                      ? {
                          'order': 3,
                          'generation': {
                            'url': 'https://pokeapi.co/api/v2/generation/1/'
                          }
                        }
                      : {
                          'type': {'name': 'normal'},
                          'damage_class': {'name': 'status'},
                          'power': null,
                          'accuracy': null
                        },
                ),
                200)))));
    final info = await source.getBattleInfo('swords-dance', 'red-blue', 'en');
    expect(info.category, 'status');
    expect(info.power, isNull);
    expect(info.accuracy, isNull);
  });
}
