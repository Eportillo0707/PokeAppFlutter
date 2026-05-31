import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/domain/usecases/type_effectiveness.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_about.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_evolutions.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/detail_stats.dart';

class PokemonInfoPage extends StatelessWidget {
  const PokemonInfoPage({
    super.key,
    required this.pokemon,
    required this.onEvolutionTap,
  });

  final PokemonInfo pokemon;
  final ValueChanged<PokemonSpecies> onEvolutionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('info-page'),
      children: [
        PokemonDescriptionPanel(pokemon: pokemon),
        PokemonSpecsPanel(pokemon: pokemon),
        PokemonAbilitiesPanel(pokemon: pokemon),
        PokemonEvolutionsPanel(
          pokemon: pokemon,
          onSpeciesTap: onEvolutionTap,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class PokemonStatsPage extends StatelessWidget {
  const PokemonStatsPage({super.key, required this.pokemon});

  final PokemonInfo pokemon;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('stats-page'),
      children: [
        PokemonStatsPanel(pokemon: pokemon),
        PokemonTypeEffectivenessPanel(
          effectiveness: getDefensiveEffectiveness(pokemon.types),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
