import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';

class TypeBadgeImage extends StatelessWidget {
  const TypeBadgeImage({super.key, required this.type, this.width = 100});

  final String type;
  final double width;

  static const _files = {
    'grass': 'grasssv.png',
    'poison': 'poisonsv.png',
    'fire': 'firesv.png',
    'water': 'watersv.png',
    'bug': 'bugsv.png',
    'normal': 'normalsv.png',
    'electric': 'electricsv.png',
    'ground': 'groundsv.png',
    'fairy': 'fairysv.png',
    'fighting': 'fightingsv.png',
    'psychic': 'psychicsv.png',
    'rock': 'rocksv.png',
    'ghost': 'ghostsv.png',
    'ice': 'iceicsv.png',
    'dragon': 'dragonsv.png',
    'dark': 'darksv.png',
    'steel': 'steelsv.png',
    'flying': 'flyingsv.png',
  };

  @override
  Widget build(BuildContext context) {
    final file = _files[type.toLowerCase()];
    if (file == null) return TypeChip(type: type, compact: true);
    return Image.asset(
      'assets/icons/$file',
      width: width,
      height: width * .38,
      fit: BoxFit.contain,
    );
  }
}

class TypeChip extends StatelessWidget {
  const TypeChip({super.key, required this.type, this.compact = false});

  final String type;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 7,
      ),
      decoration: BoxDecoration(
        color: pokemonTypeColor(type),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        formatPokemonName(type),
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 11 : 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
