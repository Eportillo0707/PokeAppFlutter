import 'package:flutter/material.dart';

import '../../models/pokemon_models.dart';
import '../../utils/pokemon_formatters.dart';
import 'detail_card.dart';

class PokemonDescriptionPanel extends StatelessWidget {
  const PokemonDescriptionPanel({super.key, required this.pokemon});

  final PokemonInfo pokemon;

  @override
  Widget build(BuildContext context) {
    return DetailPanel(
      title: 'Description',
      child: Text(
        pokemon.description.isEmpty
            ? 'Description unavailable.'
            : pokemon.description,
        style: const TextStyle(height: 1.4),
      ),
    );
  }
}

class PokemonSpecsPanel extends StatelessWidget {
  const PokemonSpecsPanel({super.key, required this.pokemon});

  final PokemonInfo pokemon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SpecColumn(label: 'Height', value: '${pokemon.height / 10} m'),
          const SizedBox(width: 80),
          Container(width: 1, height: 60, color: Colors.white),
          const SizedBox(width: 30),
          _SpecColumn(label: 'Weight', value: '${pokemon.weight / 10} kg'),
        ],
      ),
    );
  }
}

class _SpecColumn extends StatelessWidget {
  const _SpecColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class PokemonAbilitiesPanel extends StatelessWidget {
  const PokemonAbilitiesPanel({super.key, required this.pokemon});

  final PokemonInfo pokemon;

  @override
  Widget build(BuildContext context) {
    return DetailPanel(
      title: 'Abilities',
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 5,
          runSpacing: 8,
          children: pokemon.abilities
              .map(
                (ability) => TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF232B4C),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _showAbilitySheet(context, ability),
                  child: Text(
                    formatPokemonName(ability.name),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showAbilitySheet(BuildContext context, PokemonAbility ability) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF232B4C),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatPokemonName(ability.name),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              ability.flavorText,
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
