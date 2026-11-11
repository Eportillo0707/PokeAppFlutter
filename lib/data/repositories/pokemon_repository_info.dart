part of 'pokemon_repository_impl.dart';

mixin _RepositoryInfo on _RepositoryBase {
  @override
  Future<PokemonInfo> getPokemonInfo(
    String name, {
    String languageCode = 'en',
  }) async {
    final pokemon = await _remoteDataSource.getPokemon(name);
    final species = await _getSpeciesOrNull(pokemon);
    final evolutionChain = await _getEvolutionChainOrNull(species);
    final normalEvolutions = _mapper.mapEvolutionSpecies(
      evolutionChain,
      languageCode: languageCode,
    );
    final megaEvolutions = await _getMegaEvolutions(
      normalEvolutions,
      languageCode,
    );
    final regionalForms = await _getRegionalForms(
      normalEvolutions,
      languageCode,
    );
    final gigantamaxForms = await _getGigantamaxForms(
      normalEvolutions,
      languageCode,
    );
    final abilityDtos = await _getAbilities(pokemon);

    return _mapper.mapPokemonInfo(
      pokemon: pokemon,
      species: species,
      evolutionChain: evolutionChain,
      abilities: abilityDtos,
      megaEvolutions: megaEvolutions,
      regionalForms: regionalForms,
      gigantamaxForms: gigantamaxForms,
      languageCode: languageCode,
    );
  }
}
