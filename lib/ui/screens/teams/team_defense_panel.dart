import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/domain/usecases/type_effectiveness.dart';
import 'package:pokeapp_flutter/ui/components/type_badge.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';
import 'team_pokemon_picker.dart';
part 'team_defense_presentation.dart';
part 'team_defense_members.dart';

double teamDefenseMultiplier(PokemonItem pokemon, String attackType) =>
    pokemon.types.fold<double>(1,
        (value, type) => value * (defenseMultipliers[type]?[attackType] ?? 1));

class TeamDefensePanel extends StatefulWidget {
  const TeamDefensePanel({super.key, required this.members});
  final List<PokemonItem> members;

  @override
  State<TeamDefensePanel> createState() => _TeamDefensePanelState();
}

class _TeamDefensePanelState extends State<TeamDefensePanel> {
  void _updateState(VoidCallback change) => setState(change);
  bool weak = true;
  bool expanded = false;
  List<PokemonItem> get members => widget.members;
  List<PokemonItem> affected(String type, bool weak) => members.where((p) {
        final value = teamDefenseMultiplier(p, type);
        return weak ? value > 1 : value < 1;
      }).toList()
        ..sort((a, b) => weak
            ? teamDefenseMultiplier(b, type)
                .compareTo(teamDefenseMultiplier(a, type))
            : teamDefenseMultiplier(a, type)
                .compareTo(teamDefenseMultiplier(b, type)));

  @override
  Widget build(BuildContext context) {
    final es = context.l10n.isSpanish;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 16),
      Text(es ? 'Balance defensivo' : 'Defensive balance',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(
          es
              ? 'Toca un tipo para ver los Pokémon afectados. Se consideran los tipos, sin habilidades ni objetos.'
              : 'Tap a type to see affected Pokémon. Based on types, excluding abilities and items.',
          style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 16),
      Wrap(spacing: 8, children: [
        ChoiceChip(
            label: Text(es ? 'Debilidades' : 'Weaknesses'),
            selected: weak,
            onSelected: (_) => setState(() {
                  weak = true;
                  expanded = false;
                })),
        ChoiceChip(
            label: Text(es ? 'Resistencias' : 'Resistances'),
            selected: !weak,
            onSelected: (_) => setState(() {
                  weak = false;
                  expanded = false;
                })),
      ]),
      const SizedBox(height: 12),
      _group(context, weak),
    ]);
  }
}
