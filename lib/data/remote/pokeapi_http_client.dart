import 'dart:convert';

import 'package:http/http.dart' as http;

class PokeApiHttpClient {
  PokeApiHttpClient({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://pokeapi.co/api/v2';
  final http.Client _client;

  Future<Map<String, dynamic>> getJson(String path) {
    return getAbsoluteJson('$_baseUrl$path');
  }

  Future<Map<String, dynamic>> getAbsoluteJson(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('PokeAPI request failed: ${response.statusCode} $url');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
