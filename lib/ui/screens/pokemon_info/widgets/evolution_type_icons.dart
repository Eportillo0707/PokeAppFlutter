import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/ui/components/type_icons.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';

class EvolutionTypeIcons extends StatelessWidget {
  const EvolutionTypeIcons({super.key, required this.types});

  final List<String> types;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final type in types.take(2))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: CircleAvatar(
                radius: 11,
                backgroundColor: pokemonTypeColor(type),
                child:
                    Icon(pokemonTypeIcon(type), size: 13, color: Colors.white),
              ),
            ),
        ],
      );
}
