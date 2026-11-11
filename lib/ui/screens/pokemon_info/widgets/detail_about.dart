import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'detail_card.dart';

export 'detail_abilities_panel.dart';
export 'detail_specs_panel.dart';

class PokemonDescriptionPanel extends StatelessWidget {
  const PokemonDescriptionPanel({super.key, required this.pokemon});

  final PokemonInfo pokemon;

  @override
  Widget build(BuildContext context) {
    return DetailPanel(
      title: context.l10n.description,
      revealOnScroll: false,
      child: Text(
        pokemon.description.isEmpty
            ? context.l10n.descriptionUnavailable
            : pokemon.description,
        style: const TextStyle(height: 1.4),
      ),
    );
  }
}
