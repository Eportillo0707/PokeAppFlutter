import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/scroll_reveal.dart';

class PokemonSpecsPanel extends StatelessWidget {
  const PokemonSpecsPanel({super.key, required this.pokemon});

  final PokemonInfo pokemon;

  @override
  Widget build(BuildContext context) {
    return ScrollReveal(
        child: Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columnWidth = (constraints.maxWidth * .28).clamp(115.0, 180.0);
          final sideGap = (constraints.maxWidth * .10).clamp(28.0, 58.0);
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SpecBox(
                  width: columnWidth,
                  label: context.l10n.height,
                  value: '${pokemon.height / 10} m'),
              SizedBox(width: sideGap),
              Container(width: 1, height: 60, color: Colors.white),
              SizedBox(width: sideGap),
              _SpecBox(
                  width: columnWidth,
                  label: context.l10n.weight,
                  value: '${pokemon.weight / 10} kg'),
            ],
          );
        },
      ),
    ));
  }
}

class _SpecBox extends StatelessWidget {
  const _SpecBox({
    required this.width,
    required this.label,
    required this.value,
  });

  final double width;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                softWrap: false,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
