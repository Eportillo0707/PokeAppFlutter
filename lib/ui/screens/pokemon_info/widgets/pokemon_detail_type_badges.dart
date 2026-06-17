import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/ui/components/pokemon_widgets.dart';

class PokemonDetailTypeBadges extends StatelessWidget {
  const PokemonDetailTypeBadges({super.key, required this.types});

  final List<String> types;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 430).clamp(1.0, 1.35);
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: types
                .map(
                  (type) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                    child: TypeBadgeImage(type: type, width: 150 * scale),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
