import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_connector.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/evolution_item.dart';
import 'mega_stone_names.dart';
import 'mega_stone_names_extra.dart';

class MegaEvolutionGroup extends StatelessWidget {
  const MegaEvolutionGroup(
      {super.key,
      required this.parent,
      required this.forms,
      required this.currentPokemonId,
      required this.onSpeciesTap});

  final PokemonSpecies? parent;
  final List<PokemonSpecies> forms;
  final int currentPokemonId;
  final ValueChanged<PokemonSpecies> onSpeciesTap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          if (parent == null) {
            final width = constraints.maxWidth / forms.length.clamp(1, 3);
            return Wrap(
                spacing: 6,
                alignment: WrapAlignment.center,
                children: [for (final form in forms) _item(form, width)]);
          }
          if (forms.length == 1) {
            final width = (constraints.maxWidth - 48) / 2;
            return Row(children: [
              _item(parent!, width, isParent: true),
              EvolutionConnector(
                  target: forms.first,
                  width: 48,
                  showDetails: false,
                  mega: true,
                  stoneAsset: _stoneFor(forms.first)),
              _item(forms.first, width),
            ]);
          }
          final width = (constraints.maxWidth - 56) / 3;
          return Column(children: [
            Row(children: [
              _item(forms.first, width),
              EvolutionConnector(
                  target: forms.first,
                  width: 28,
                  reverse: true,
                  showDetails: false,
                  mega: true,
                  stoneAsset: _stoneFor(forms.first)),
              _item(parent!, width, isParent: true),
              EvolutionConnector(
                  target: forms[1],
                  width: 28,
                  showDetails: false,
                  mega: true,
                  stoneAsset: _stoneFor(forms[1])),
              _item(forms[1], width),
            ]),
            if (forms.length > 2)
              Wrap(alignment: WrapAlignment.center, children: [
                for (final form in forms.skip(2)) _item(form, width),
              ]),
          ]);
        },
      );

  Widget _item(PokemonSpecies species, double width, {bool isParent = false}) =>
      EvolutionItem(
        species: species,
        width: width,
        height: 210,
        hero: !isParent && species.id != currentPokemonId,
        showMethod: !isParent,
        onTap: () => onSpeciesTap(species),
      );

  String? _stoneFor(PokemonSpecies form) {
    final stone = megaStoneNames[form.name] ?? megaStoneNamesExtra[form.name];
    return stone == null ? null : 'assets/offline_catalog/items/$stone';
  }
}
