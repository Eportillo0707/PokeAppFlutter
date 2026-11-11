import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_move.dart';
import 'detail_moves.dart';
import 'detail_pages.dart';

class PokemonDetailPageContent extends StatelessWidget {
  const PokemonDetailPageContent({
    super.key,
    required this.pokemon,
    required this.selectedPage,
    required this.onEvolutionTap,
    this.loadMachines,
    this.loadDescription,
    this.loadBattleInfo,
  });

  final PokemonInfo pokemon;
  final int selectedPage;
  final ValueChanged<PokemonSpecies> onEvolutionTap;
  final MoveMachineLoader? loadMachines;
  final MoveDescriptionLoader? loadDescription;
  final MoveBattleLoader? loadBattleInfo;

  @override
  Widget build(BuildContext context) => switch (selectedPage) {
        0 => PokemonInfoPage(
            pokemon: pokemon,
            onEvolutionTap: onEvolutionTap,
          ),
        1 => PokemonStatsPage(pokemon: pokemon),
        _ => PokemonMovesPage(
            key: ValueKey('moves-${pokemon.id}'),
            moves: pokemon.moves,
            pokemonId: pokemon.id,
            loadMachines: loadMachines,
            loadDescription: loadDescription,
            loadBattleInfo: loadBattleInfo,
          ),
      };
}
