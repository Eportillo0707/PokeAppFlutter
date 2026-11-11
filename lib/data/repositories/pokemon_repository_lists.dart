part of 'pokemon_repository_impl.dart';

mixin _RepositoryLists on _RepositoryBase {
  @override
  Future<List<PokemonItem>> getPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _remoteDataSource.getPokemonList(
      limit: limit,
      offset: offset,
    );
    final results = List<Map<String, dynamic>>.from(data['results'] as List);
    final items = await Future.wait(
      results.map((item) => getPokemonItem(item['name'] as String)),
    );
    items.sort((a, b) => a.id.compareTo(b.id));
    return items;
  }

  @override
  Future<List<PokemonItem>> searchPokemon(String query) async {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return [];
    try {
      return [await getPokemonItem(trimmed)];
    } catch (_) {
      final data = await _remoteDataSource.getAllPokemonNames();
      final results = List<Map<String, dynamic>>.from(data['results'] as List);
      final matches = results
          .where((item) => (item['name'] as String).contains(trimmed))
          .take(40)
          .toList();
      return Future.wait(matches.map((item) => getPokemonItem(item['name'])));
    }
  }

  @override
  Future<List<PokemonItem>> getPokemonByType(String type) async {
    final data = await _remoteDataSource.getPokemonByType(type);
    final pokemon = List<Map<String, dynamic>>.from(data['pokemon'] as List);
    final items = await Future.wait(
      pokemon.map((slot) => getPokemonItem(slot['pokemon']['name'] as String)),
    );
    items.sort((a, b) => a.id.compareTo(b.id));
    return items;
  }

  @override
  Future<List<PokemonItem>> getPokemonByGeneration(
    PokemonGeneration generation, {
    int limit = 20,
    int offset = 0,
  }) async {
    final total = generation.endId - generation.startId + 1;
    if (offset >= total) return [];
    final pageSize = limit.clamp(0, total - offset).toInt();
    final ids = List<int>.generate(
      pageSize,
      (index) => generation.startId + offset + index,
    );
    final items = await Future.wait(
      ids.map((id) => getPokemonItem('$id')),
    );
    items.sort((a, b) => a.id.compareTo(b.id));
    return items;
  }

  @override
  Future<PokemonItem> getPokemonItem(String name) async {
    final detail = await _remoteDataSource.getPokemon(name);
    return _mapper.mapPokemonItem(detail);
  }
}
