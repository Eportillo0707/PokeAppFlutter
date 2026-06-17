import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/usecases/type_effectiveness.dart';
import 'package:pokeapp_flutter/ui/components/pokemon_widgets.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';

class PokemonTypeEffectivenessPanel extends StatelessWidget {
  const PokemonTypeEffectivenessPanel({super.key, required this.effectiveness});

  final TypeEffectiveness effectiveness;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TypeGroup(
          title: context.l10n.resistances,
          label: context.l10n.multiplierFrom('1/2x'),
          types: effectiveness.resistantTo,
        ),
        TypeGroup(
          label: context.l10n.multiplierFrom('1/4x'),
          types: effectiveness.veryResistantTo,
        ),
        TypeGroup(
            label: context.l10n.immunities, types: effectiveness.immuneTo),
        TypeGroup(
          title: context.l10n.weaknesses,
          label: context.l10n.multiplierFrom('4x'),
          types: effectiveness.veryWeakTo,
        ),
        TypeGroup(
          label: context.l10n.multiplierFrom('2x'),
          types: effectiveness.weakTo,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class TypeGroup extends StatelessWidget {
  const TypeGroup(
      {super.key, this.title, required this.label, required this.types});

  final String? title;
  final String label;
  final List<String> types;

  @override
  Widget build(BuildContext context) {
    if (types.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
            ),
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: types
                .map((type) => TypeBadgeImage(type: type, width: 100))
                .toList(),
          ),
        ],
      ),
    );
  }
}
