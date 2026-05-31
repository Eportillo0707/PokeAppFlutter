import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_generation.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';

class GenerationFilterSheet extends StatelessWidget {
  const GenerationFilterSheet({
    super.key,
    required this.selectedGeneration,
    required this.onSelected,
  });

  final PokemonGeneration? selectedGeneration;
  final ValueChanged<PokemonGeneration?> onSelected;

  static const _background = Color(0xFF121422);
  static const _surface = Color(0xFF232B4C);
  static const _selectedSurface = Color(0xFF30385F);
  static const _accent = Color(0xFFE8D8FF);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: _background),
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
                  color: _accent,
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
                    return _GenerationCard(
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
                child: _AllGenerationsButton(
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

class _GenerationCard extends StatelessWidget {
  const _GenerationCard({
    required this.generation,
    required this.selected,
    required this.onTap,
  });

  final PokemonGeneration generation;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
        decoration: BoxDecoration(
          color: selected
              ? GenerationFilterSheet._selectedSurface
              : GenerationFilterSheet._surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? GenerationFilterSheet._accent : Colors.white12,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .18),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                context.l10n.generationName(generation.romanNumeral),
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: generation.starterIds
                    .map((id) => _StarterImage(id: id))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllGenerationsButton extends StatelessWidget {
  const _AllGenerationsButton({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? GenerationFilterSheet._selectedSurface
              : GenerationFilterSheet._surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? GenerationFilterSheet._accent : Colors.white12,
          ),
        ),
        child: Center(
          child: Text(
            context.l10n.allGenerations,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _StarterImage extends StatelessWidget {
  const _StarterImage({required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Image.network(
        officialPokemonArtworkUrl(id),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
