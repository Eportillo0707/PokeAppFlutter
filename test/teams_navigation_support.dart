part of 'teams_navigation_test.dart';

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
