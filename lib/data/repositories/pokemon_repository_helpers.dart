part of 'pokemon_repository_impl.dart';

mixin _RepositoryHelpers on _RepositoryBase {
  @override
  Future<Map<String, dynamic>?> _getSpeciesOrNull(
    Map<String, dynamic> pokemon,
  ) async {
    try {
      return await _remoteDataSource.getPokemonSpecies(
        pokemon['species']['name'] as String,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> _getEvolutionChainOrNull(
    Map<String, dynamic>? species,
  ) async {
    try {
      final url = species?['evolution_chain']?['url'] as String?;
      if (url == null) return null;
      return await _remoteDataSource.getAbsoluteJson(url);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> _getAbilities(
    Map<String, dynamic> pokemon,
  ) async {
    final abilities = await Future.wait(
      List<Map<String, dynamic>>.from(pokemon['abilities'] as List).map(
        (slot) async {
          try {
            return await _remoteDataSource.getAbility(
              slot['ability']['name'] as String,
            );
          } catch (_) {
            return null;
          }
        },
      ),
    );
    return abilities.whereType<Map<String, dynamic>>().toList();
  }
}
