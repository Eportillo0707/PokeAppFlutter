class PokemonGeneration {
  const PokemonGeneration({
    required this.id,
    required this.startId,
    required this.endId,
    required this.starterIds,
  });

  final int id;
  final int startId;
  final int endId;
  final List<int> starterIds;

  String get romanNumeral {
    return switch (id) {
      1 => 'I',
      2 => 'II',
      3 => 'III',
      4 => 'IV',
      5 => 'V',
      6 => 'VI',
      7 => 'VII',
      8 => 'VIII',
      9 => 'IX',
      _ => '$id',
    };
  }
}

const pokemonGenerations = [
  PokemonGeneration(id: 1, startId: 1, endId: 151, starterIds: [1, 4, 7]),
  PokemonGeneration(
      id: 2, startId: 152, endId: 251, starterIds: [152, 155, 158]),
  PokemonGeneration(
      id: 3, startId: 252, endId: 386, starterIds: [252, 255, 258]),
  PokemonGeneration(
      id: 4, startId: 387, endId: 493, starterIds: [387, 390, 393]),
  PokemonGeneration(
      id: 5, startId: 494, endId: 649, starterIds: [495, 498, 501]),
  PokemonGeneration(
      id: 6, startId: 650, endId: 721, starterIds: [650, 653, 656]),
  PokemonGeneration(
      id: 7, startId: 722, endId: 809, starterIds: [722, 725, 728]),
  PokemonGeneration(
      id: 8, startId: 810, endId: 905, starterIds: [810, 813, 816]),
  PokemonGeneration(
      id: 9, startId: 906, endId: 1025, starterIds: [906, 909, 912]),
];

String officialPokemonArtworkUrl(int id) {
  return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}
