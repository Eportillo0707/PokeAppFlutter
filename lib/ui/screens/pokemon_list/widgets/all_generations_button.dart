import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_list/widgets/generation_filter_style.dart';

class AllGenerationsButton extends StatelessWidget {
  const AllGenerationsButton({
    super.key,
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
              ? GenerationFilterStyle.selectedSurface
              : GenerationFilterStyle.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? GenerationFilterStyle.accent : Colors.white12,
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
