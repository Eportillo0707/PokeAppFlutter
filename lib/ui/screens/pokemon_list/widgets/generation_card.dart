import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_generation.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/widgets/generation_filter_style.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/widgets/generation_starter_image.dart';

class GenerationCard extends StatelessWidget {
  const GenerationCard({
    super.key,
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
        decoration: _decoration,
        child: Column(
          children: [
            _GenerationTitle(generation: generation),
            const SizedBox(height: 2),
            Expanded(child: _StarterRow(ids: generation.starterIds)),
          ],
        ),
      ),
    );
  }

  BoxDecoration get _decoration => BoxDecoration(
        color: selected
            ? GenerationFilterStyle.selectedSurface
            : GenerationFilterStyle.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? GenerationFilterStyle.accent : Colors.white12,
          width: selected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .18),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      );
}

class _GenerationTitle extends StatelessWidget {
  const _GenerationTitle({required this.generation});

  final PokemonGeneration generation;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
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
    );
  }
}

class _StarterRow extends StatelessWidget {
  const _StarterRow({required this.ids});

  final List<int> ids;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ids.map((id) => GenerationStarterImage(id: id)).toList(),
    );
  }
}
