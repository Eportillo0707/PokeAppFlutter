part of 'pokemon_repository_impl.dart';

mixin _RepositoryForms on _RepositoryBase {
  @override
  Future<List<PokemonSpecies>> _getMegaEvolutions(
    List<PokemonSpecies> baseSpecies,
    String languageCode,
  ) async {
    return _getForms(
      baseSpecies,
      matches: (name) => name.contains('-mega'),
      methodFor: (_) =>
          languageCode == 'es' ? 'Megaevolucion' : 'Mega Evolution',
    );
  }

  @override
  Future<List<PokemonSpecies>> _getRegionalForms(
    List<PokemonSpecies> baseSpecies,
    String languageCode,
  ) async {
    return _getForms(
      baseSpecies,
      matches: _isRegionalForm,
      methodFor: (name) => _regionalFormLabel(name, languageCode),
    );
  }

  @override
  Future<List<PokemonSpecies>> _getGigantamaxForms(
    List<PokemonSpecies> baseSpecies,
    String languageCode,
  ) async {
    return _getForms(
      baseSpecies,
      matches: (name) => name.contains('-gmax'),
      methodFor: (_) => languageCode == 'es' ? 'Gigamax' : 'Gigantamax',
    );
  }

  Future<List<PokemonSpecies>> _getForms(
    List<PokemonSpecies> baseSpecies, {
    required bool Function(String name) matches,
    required String Function(String name) methodFor,
  }) async {
    final all = <PokemonSpecies>[];
    for (final base in baseSpecies) {
      try {
        final species = await _remoteDataSource.getPokemonSpecies(base.name);
        final varieties = List<Map<String, dynamic>>.from(
          species['varieties'] as List? ?? [],
        );
        for (final variety in varieties) {
          final varietyName =
              (variety['pokemon']['name'] as String).toLowerCase();
          if (!matches(varietyName)) continue;
          final detail = await _remoteDataSource.getPokemon(varietyName);
          all.add(
            PokemonSpecies(
              id: detail['id'] as int,
              name: detail['name'] as String,
              evolvesFromSpeciesId: base.id,
              evolutionMethod: methodFor(varietyName),
            ),
          );
        }
      } catch (_) {}
    }
    all.sort((a, b) => a.id.compareTo(b.id));
    return _mapper.distinctSpecies(all);
  }

  bool _isRegionalForm(String name) {
    return name.contains('-alola') ||
        name.contains('-galar') ||
        name.contains('-hisui') ||
        name.contains('-paldea');
  }

  String _regionalFormLabel(String name, String languageCode) {
    final region = _regionalName(name, languageCode);
    return languageCode == 'es' ? 'Forma $region' : '$region Form';
  }

  String _regionalName(String name, String languageCode) {
    if (name.contains('-alola')) return 'Alola';
    if (name.contains('-galar')) return 'Galar';
    if (name.contains('-hisui')) return 'Hisui';
    if (name.contains('-paldea')) return 'Paldea';
    return languageCode == 'es' ? 'regional' : 'Regional';
  }
}
