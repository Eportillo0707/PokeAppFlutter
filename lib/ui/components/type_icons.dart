import 'package:flutter/material.dart';

IconData pokemonTypeIcon(String value) {
  return switch (value.toLowerCase()) {
    'fire' => Icons.local_fire_department,
    'water' => Icons.water_drop,
    'grass' => Icons.grass,
    'electric' => Icons.bolt,
    'poison' => Icons.science,
    'ground' => Icons.terrain,
    'flying' => Icons.air,
    'psychic' => Icons.blur_on,
    'bug' => Icons.bug_report,
    'rock' => Icons.hexagon,
    'ghost' => Icons.nightlight,
    'dragon' => Icons.whatshot,
    'dark' => Icons.dark_mode,
    'steel' => Icons.shield,
    'fairy' => Icons.auto_awesome,
    'ice' => Icons.ac_unit,
    'fighting' => Icons.sports_mma,
    _ => Icons.circle,
  };
}
