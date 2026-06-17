part of 'pokemon_card.dart';

class _PokemonImage extends StatelessWidget {
  const _PokemonImage({required this.pokemon});

  final PokemonItem pokemon;

  @override
  Widget build(BuildContext context) {
    final imageSize = (MediaQuery.sizeOf(context).width * .26).clamp(
      100.0,
      230.0,
    );
    return Hero(
      tag: 'pokemon-image-${pokemon.name}',
      transitionOnUserGestures: true,
      child: Image.network(
        pokemon.imageUrl,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.contain,
        cacheWidth: (imageSize * 1.8).round(),
        cacheHeight: (imageSize * 1.8).round(),
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) => SizedBox(height: imageSize),
      ),
    );
  }
}
