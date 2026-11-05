typedef MoveMachineLoader = Future<List<String>> Function(
    String move, String game);

typedef MoveBattleLoader = Future<MoveBattleInfo> Function(
    String move, String game, String language);

class MoveBattleInfo {
  const MoveBattleInfo(
      {required this.name,
      required this.type,
      required this.category,
      this.power,
      this.pp,
      this.generation,
      this.accuracy});
  final String name;
  final String type;
  final String category;
  final int? power;
  final int? pp;
  final String? generation;
  final int? accuracy;
}

typedef MoveDescriptionLoader = Future<MoveDescription?> Function(
    String move, String game, String language);

class MoveDescription {
  const MoveDescription(
      {required this.text, required this.game, required this.language});
  final String text;
  final String game;
  final String language;
}

class PokemonMove {
  const PokemonMove({required this.name, required this.learning});

  final String name;
  final List<MoveLearning> learning;
}

class MoveLearning {
  const MoveLearning({
    required this.game,
    required this.gameId,
    required this.method,
    required this.level,
  });

  final String game;
  final int gameId;
  final String method;
  final int level;
}
