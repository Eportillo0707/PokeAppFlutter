import 'package:pokeapp_flutter/data/remote/mappers/pokemon_mapper.dart';
import 'package:pokeapp_flutter/data/remote/move_machine_source.dart';
import 'package:pokeapp_flutter/data/remote/pokemon_remote_data_source.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_generation.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_move.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';

part 'pokemon_repository_lists.dart';
part 'pokemon_repository_info.dart';
part 'pokemon_repository_helpers.dart';
part 'pokemon_repository_forms.dart';

abstract class _RepositoryBase {
  PokemonRemoteDataSource get _remoteDataSource;
  PokemonMapper get _mapper;
  Future<PokemonItem> getPokemonItem(String name);
  Future<List<PokemonItem>> getPokemonList({int limit = 20, int offset = 0});
  Future<List<PokemonItem>> searchPokemon(String query);
  Future<List<PokemonItem>> getPokemonByType(String type);
  Future<List<PokemonItem>> getPokemonByGeneration(PokemonGeneration generation,
      {int limit = 20, int offset = 0});
  Future<PokemonInfo> getPokemonInfo(String name, {String languageCode = 'en'});
  Future<Map<String, dynamic>?> _getSpeciesOrNull(Map<String, dynamic> pokemon);
  Future<Map<String, dynamic>?> _getEvolutionChainOrNull(
      Map<String, dynamic>? species);
  Future<List<Map<String, dynamic>>> _getAbilities(
      Map<String, dynamic> pokemon);
  Future<List<PokemonSpecies>> _getMegaEvolutions(
      List<PokemonSpecies> species, String language);
  Future<List<PokemonSpecies>> _getRegionalForms(
      List<PokemonSpecies> species, String language);
  Future<List<PokemonSpecies>> _getGigantamaxForms(
      List<PokemonSpecies> species, String language);
}

class PokemonRepositoryImpl extends _RepositoryBase
    with _RepositoryLists, _RepositoryInfo, _RepositoryHelpers, _RepositoryForms
    implements PokemonRepository {
  PokemonRepositoryImpl({
    required PokemonRemoteDataSource remoteDataSource,
    required PokemonMapper mapper,
  })  : _remoteDataSource = remoteDataSource,
        _mapper = mapper;

  @override
  final PokemonRemoteDataSource _remoteDataSource;
  @override
  final PokemonMapper _mapper;
  late final _moveMachines = MoveMachineSource(_remoteDataSource);

  @override
  Future<MoveBattleInfo> getMoveBattleInfo(
          String move, String game, String language) =>
      _moveMachines.getBattleInfo(move, game, language);

  @override
  Future<MoveDescription?> getMoveDescription(
          String move, String game, String language) =>
      _moveMachines.getDescription(move, game, language);

  @override
  Future<List<String>> getMoveMachines(String move, String game) =>
      _moveMachines.getMachines(move, game);
}
