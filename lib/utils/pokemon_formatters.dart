import 'package:flutter/material.dart';

String formatPokemonName(String value) {
  return value
      .split('-')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

String cleanFlavorText(String value) {
  return value.replaceAll('\n', ' ').replaceAll('\f', ' ').replaceAll(
        RegExp(r'\s+'),
        ' ',
      ).trim();
}

int idFromUrl(String url) {
  final clean = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  return int.tryParse(clean.split('/').last) ?? 0;
}

Color pokemonTypeColor(String? type) {
  switch (type) {
    case 'normal':
      return const Color(0xFF9FA19E);
    case 'fire':
      return const Color(0xFFE62828);
    case 'water':
      return const Color(0xFF2981EF);
    case 'electric':
      return const Color(0xFFFABF00);
    case 'grass':
      return const Color(0xFF3FA12A);
    case 'ice':
      return const Color(0xFF96D9D6);
    case 'fighting':
      return const Color(0xFFFF8000);
    case 'poison':
      return const Color(0xFFA33EA1);
    case 'ground':
      return const Color(0xFF915121);
    case 'flying':
      return const Color(0xFF689DFE);
    case 'psychic':
      return const Color(0xFFEE4179);
    case 'bug':
      return const Color(0xFF91A11A);
    case 'rock':
      return const Color(0xFFAFA981);
    case 'ghost':
      return const Color(0xFF704170);
    case 'dragon':
      return const Color(0xFF5160E1);
    case 'dark':
      return const Color(0xFF50413F);
    case 'steel':
      return const Color(0xFF60A1B8);
    case 'fairy':
      return const Color(0xFFD685AD);
    default:
      return Colors.grey;
  }
}

const pokemonTypes = [
  'fire',
  'water',
  'grass',
  'electric',
  'psychic',
  'ice',
  'dragon',
  'dark',
  'fairy',
  'fighting',
  'poison',
  'ground',
  'flying',
  'normal',
  'bug',
  'rock',
  'ghost',
  'steel',
];
