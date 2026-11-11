import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokeapp_flutter/data/remote/move_machine_source.dart';
import 'package:pokeapp_flutter/data/remote/pokeapi_http_client.dart';
import 'package:pokeapp_flutter/data/remote/pokemon_remote_data_source.dart';

void main() {
  test(
      'resolves exact game items, reuses cache and does not infer absent games',
      () async {
    final requests = <String>[];
    final games = {
      '1': ('red-blue', 'hm03'),
      '2': ('sword-shield', 'tr04'),
      '3': ('scarlet-violet', 'tm123')
    };
    final client = MockClient((request) async {
      requests.add(request.url.path);
      if (request.url.path.contains('/move/')) {
        return http.Response(
            jsonEncode({
              'machines': [
                for (final entry in games.entries)
                  {
                    'version_group': {'name': entry.value.$1},
                    'machine': {
                      'url': 'https://pokeapi.co/api/v2/machine/${entry.key}/'
                    }
                  },
              ]
            }),
            200);
      }
      final id = request.url.pathSegments.where((s) => s.isNotEmpty).last;
      final game = games[id]!;
      return http.Response(
          jsonEncode({
            'move': {'name': 'surf'},
            'version_group': {'name': game.$1},
            'item': {'name': game.$2},
          }),
          200);
    });
    final source = MoveMachineSource(
        PokemonRemoteDataSource(client: PokeApiHttpClient(client: client)));
    expect(await source.getMachines('surf', 'red-blue'), ['hm03']);
    expect(await source.getMachines('surf', 'sword-shield'), ['tr04']);
    expect(await source.getMachines('surf', 'scarlet-violet'), ['tm123']);
    expect(await source.getMachines('surf', 'red-blue'), ['hm03']);
    expect(await source.getMachines('surf', 'unknown'), isEmpty);
    expect(requests.length, 4);
  });

  test('failed requests can be retried', () async {
    var requests = 0;
    final source = MoveMachineSource(PokemonRemoteDataSource(
        client: PokeApiHttpClient(
      client: MockClient((_) async => ++requests == 1
          ? http.Response('Unavailable', 503)
          : http.Response('{"machines":[]}', 200)),
    )));
    await expectLater(source.getMachines('surf', 'red-blue'), throwsException);
    expect(await source.getMachines('surf', 'red-blue'), isEmpty);
    expect(requests, 2);
  });

  test('rejects machine data for a different move or game', () async {
    final source = MoveMachineSource(PokemonRemoteDataSource(
        client: PokeApiHttpClient(
      client: MockClient((request) async => http.Response(
          jsonEncode(
            request.url.path.contains('/move/')
                ? {
                    'machines': [
                      {
                        'version_group': {'name': 'red-blue'},
                        'machine': {
                          'url': 'https://pokeapi.co/api/v2/machine/1/'
                        }
                      }
                    ]
                  }
                : {
                    'move': {'name': 'cut'},
                    'version_group': {'name': 'red-blue'},
                    'item': {'name': 'hm01'}
                  },
          ),
          200)),
    )));
    expect(await source.getMachines('surf', 'red-blue'), isEmpty);
  });
}
