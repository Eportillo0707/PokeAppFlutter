import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';
import 'detail_card.dart';

class PokemonAbilitiesPanel extends StatelessWidget {
  const PokemonAbilitiesPanel({super.key, required this.pokemon});

  final PokemonInfo pokemon;

  @override
  Widget build(BuildContext context) {
    return DetailPanel(
      title: context.l10n.abilities,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 5,
          runSpacing: 8,
          children: pokemon.abilities
              .map((ability) => _AbilityButton(ability: ability))
              .toList(),
        ),
      ),
    );
  }
}

class _AbilityButton extends StatelessWidget {
  const _AbilityButton({required this.ability});

  final PokemonAbility ability;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: .14),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      onPressed: () => _showAbilitySheet(context, ability),
      child: Text(
        formatPokemonName(ability.name),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  void _showAbilitySheet(BuildContext context, PokemonAbility ability) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF232B4C),
      builder: (_) => _AbilitySheet(ability: ability),
    );
  }
}

class _AbilitySheet extends StatelessWidget {
  const _AbilitySheet({required this.ability});

  final PokemonAbility ability;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatPokemonName(ability.name),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 35, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Text(
            ability.flavorText,
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
