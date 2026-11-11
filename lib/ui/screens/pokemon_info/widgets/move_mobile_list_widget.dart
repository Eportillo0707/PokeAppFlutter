part of 'move_mobile_list.dart';

class MoveMobileList extends StatefulWidget {
  const MoveMobileList(
      {super.key,
      required this.moves,
      this.pokemonId,
      required this.game,
      required this.games,
      required this.onGame,
      this.loadMachines,
      this.loadDescription,
      this.loadBattleInfo});
  final List<PokemonMove> moves;
  final int? pokemonId;
  final String game;
  final List<String> games;
  final ValueChanged<String> onGame;
  final MoveMachineLoader? loadMachines;
  final MoveDescriptionLoader? loadDescription;
  final MoveBattleLoader? loadBattleInfo;
  @override
  State<MoveMobileList> createState() => _MoveMobileListState();
}
