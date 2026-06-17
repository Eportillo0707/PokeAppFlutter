import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_section.dart';

class PokemonEvolutionsPanel extends StatelessWidget {
  const PokemonEvolutionsPanel({
    super.key,
    required this.pokemon,
    required this.onSpeciesTap,
  });

  final PokemonInfo pokemon;
  final ValueChanged<PokemonSpecies> onSpeciesTap;

  @override
  Widget build(BuildContext context) {
    final normal = _withoutMega(pokemon.evolutionChain);
    final mega = pokemon.megaEvolutions.isNotEmpty
        ? pokemon.megaEvolutions
        : _onlyMega(pokemon.evolutionChain);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section(context.l10n.evolutionChain, normal, showArrows: true),
        _section(context.l10n.regionalForms, pokemon.regionalForms),
        _section(context.l10n.gigantamaxForms, pokemon.gigantamaxForms),
        _section(context.l10n.megaEvolutions, mega),
      ].whereType<Widget>().toList(),
    );
  }

  Widget? _section(
    String title,
    List<PokemonSpecies> species, {
    bool showArrows = false,
  }) {
    if (species.isEmpty) return null;
    return EvolutionSection(
      title: title,
      species: species,
      showArrows: showArrows,
      onSpeciesTap: onSpeciesTap,
    );
  }

  List<PokemonSpecies> _withoutMega(List<PokemonSpecies> species) {
    return species
        .where((item) => !item.name.toLowerCase().contains('-mega'))
        .toList();
  }

  List<PokemonSpecies> _onlyMega(List<PokemonSpecies> species) {
    return species
        .where((item) => item.name.toLowerCase().contains('-mega'))
        .toList();
  }
}
