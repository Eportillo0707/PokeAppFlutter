import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_method_label.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';

class EvolutionItem extends StatelessWidget {
  const EvolutionItem({
    super.key,
    required this.species,
    required this.onTap,
  });

  final PokemonSpecies species;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 155,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Image.network(species.imageUrl, width: 115, height: 115),
            Text(
              formatPokemonName(species.name),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                height: 1.05,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (species.evolutionMethod != null)
              EvolutionMethodLabel(
                method: species.evolutionMethod!,
                itemImageUrl: species.evolutionItemImageUrl,
              ),
          ],
        ),
      ),
    );
  }
}
