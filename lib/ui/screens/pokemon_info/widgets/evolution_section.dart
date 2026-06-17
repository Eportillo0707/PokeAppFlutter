import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_card.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_item.dart';

class EvolutionSection extends StatelessWidget {
  const EvolutionSection({
    super.key,
    required this.title,
    required this.species,
    required this.showArrows,
    required this.onSpeciesTap,
  });

  final String title;
  final List<PokemonSpecies> species;
  final bool showArrows;
  final ValueChanged<PokemonSpecies> onSpeciesTap;

  @override
  Widget build(BuildContext context) {
    return DetailPanel(
      title: title,
      child: SizedBox(
        height: 190,
        child: ListView.separated(
          padding: const EdgeInsets.only(right: 32),
          scrollDirection: Axis.horizontal,
          itemCount: species.length,
          separatorBuilder: (context, index) => _EvolutionArrow(
            visible: showArrows &&
                species[index + 1].evolvesFromSpeciesId == species[index].id,
          ),
          itemBuilder: (context, index) {
            final item = species[index];
            return EvolutionItem(
              species: item,
              onTap: () => onSpeciesTap(item),
            );
          },
        ),
      ),
    );
  }
}

class _EvolutionArrow extends StatelessWidget {
  const _EvolutionArrow({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(
          Icons.arrow_forward,
          color: visible ? Colors.white : Colors.transparent,
          size: 32,
        ),
      ),
    );
  }
}
