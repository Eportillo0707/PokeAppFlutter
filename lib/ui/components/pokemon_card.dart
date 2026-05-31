import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';
import 'type_badge.dart';

class PokemonCard extends StatelessWidget {
  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.onTap,
  });

  final PokemonItem pokemon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        color: const Color(0xFF202339),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: .12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: RepaintBoundary(
            child: Stack(
              children: [
                _PokedexNumber(id: pokemon.id),
                if (pokemon.isFavorite) const _FavoriteMark(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PokemonImage(pokemon: pokemon),
                    const SizedBox(height: 6),
                    _PokemonName(name: pokemon.name),
                    const SizedBox(height: 10),
                    _PokemonTypeRow(types: pokemon.types),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
      child: Icon(
        Icons.star,
        color: Color(0xFFFFD54F),
        size: 22,
      ),
    );
  }
}

class _PokemonImage extends StatelessWidget {
  const _PokemonImage({required this.pokemon});

  final PokemonItem pokemon;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'pokemon-image-${pokemon.name}',
      transitionOnUserGestures: true,
      child: Image.network(
        pokemon.imageUrl,
        width: 100,
        height: 100,
        fit: BoxFit.contain,
        cacheWidth: 180,
        cacheHeight: 180,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) => const SizedBox(height: 100),
      ),
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
