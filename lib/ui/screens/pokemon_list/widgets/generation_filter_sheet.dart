import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_generation.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/widgets/all_generations_button.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/widgets/generation_card.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/widgets/generation_filter_style.dart';

class GenerationFilterSheet extends StatelessWidget {
  const GenerationFilterSheet({
    super.key,
    required this.selectedGeneration,
    required this.onSelected,
  });

  final PokemonGeneration? selectedGeneration;
  final ValueChanged<PokemonGeneration?> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: GenerationFilterStyle.background),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: GenerationFilterStyle.accent,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                context.l10n.selectGeneration,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: pokemonGenerations.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.85,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final generation = pokemonGenerations[index];
                    return GenerationCard(
                      generation: generation,
                      selected: selectedGeneration?.id == generation.id,
                      onTap: () => onSelected(generation),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: AllGenerationsButton(
                  selected: selectedGeneration == null,
                  onTap: () => onSelected(null),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
