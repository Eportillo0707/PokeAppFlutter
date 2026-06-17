part of 'pokemon_card.dart';

class _PokedexNumber extends StatelessWidget {
  const _PokedexNumber({required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 2,
      top: 0,
      child: Text(
        '#${id.toString().padLeft(3, '0')}',
        style: TextStyle(
          color: Colors.white.withValues(alpha: .62),
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _FavoriteMark extends StatelessWidget {
  const _FavoriteMark();

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      right: 0,
      top: 0,
      child: Icon(Icons.star, color: Color(0xFFFFD54F), size: 22),
    );
  }
}

class _PokemonName extends StatelessWidget {
  const _PokemonName({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 24,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          formatPokemonName(name),
          maxLines: 1,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _PokemonTypeRow extends StatelessWidget {
  const _PokemonTypeRow({required this.types});

  final List<String> types;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: types
          .map(
            (type) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: TypeBadgeImage(type: type, width: 72),
            ),
          )
          .toList(),
    );
  }
}
