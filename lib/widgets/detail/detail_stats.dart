import 'package:flutter/material.dart';

import '../../models/pokemon_models.dart';
import '../../utils/type_effectiveness.dart';
import '../pokemon_widgets.dart';

class PokemonStatsPanel extends StatelessWidget {
  const PokemonStatsPanel({super.key, required this.pokemon});

  final PokemonInfo pokemon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      child: Column(
        children: pokemon.stats.map((stat) {
          final value = (stat.baseStat / 255).clamp(0, 1).toDouble();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stat.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${stat.baseStat}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: value),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.linear,
                  builder: (context, animatedValue, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: animatedValue,
                        minHeight: 10,
                        backgroundColor: Colors.grey.withValues(alpha: .3),
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class PokemonTypeEffectivenessPanel extends StatelessWidget {
  const PokemonTypeEffectivenessPanel({
    super.key,
    required this.effectiveness,
  });

  final TypeEffectiveness effectiveness;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TypeGroup(
          title: 'Resistances',
          label: '1/2x From:',
          types: effectiveness.resistantTo,
        ),
        _TypeGroup(
          title: null,
          label: '1/4x From:',
          types: effectiveness.veryResistantTo,
        ),
        _TypeGroup(
          title: null,
          label: 'Immunities:',
          types: effectiveness.immuneTo,
        ),
        _TypeGroup(
          title: 'Weaknesses',
          label: '4x From:',
          types: effectiveness.veryWeakTo,
        ),
        _TypeGroup(
          title: null,
          label: '2x From:',
          types: effectiveness.weakTo,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _TypeGroup extends StatelessWidget {
  const _TypeGroup({
    required this.title,
    required this.label,
    required this.types,
  });

  final String? title;
  final String label;
  final List<String> types;

  @override
  Widget build(BuildContext context) {
    if (types.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Wrap(
                alignment: WrapAlignment.start,
                spacing: 8,
                runSpacing: 4,
                children: types
                    .map((type) => TypeBadgeImage(type: type, width: 100))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
