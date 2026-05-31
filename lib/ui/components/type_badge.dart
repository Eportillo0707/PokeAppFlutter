import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';

class TypeBadgeImage extends StatelessWidget {
  const TypeBadgeImage({super.key, required this.type, this.width = 100});

  final String type;
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width * .28;
    return SizedBox(
      width: width,
      height: height.clamp(20, 42).toDouble(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: pokemonTypeColor(type),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: pokemonTypeColor(type).withValues(alpha: .35),
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .08),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _typeIcon(type),
                color: Colors.white,
                size: (width * .15).clamp(12, 22).toDouble(),
              ),
              SizedBox(width: width * .04),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    context.l10n.pokemonType(type).toUpperCase(),
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: (width * .14).clamp(10, 18).toDouble(),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _typeIcon(String value) {
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
        context.l10n.pokemonType(type),
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 11 : 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
