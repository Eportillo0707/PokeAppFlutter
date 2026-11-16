import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'evolution_route_card.dart';
import 'scroll_reveal.dart';

class EvolutionRouteList extends StatefulWidget {
  const EvolutionRouteList(
      {super.key,
      required this.title,
      required this.routes,
      required this.currentPokemonId,
      required this.heroExcludedIds,
      required this.onSpeciesTap});

  final String title;
  final List<List<PokemonSpecies>> routes;
  final int currentPokemonId;
  final Set<int> heroExcludedIds;
  final ValueChanged<PokemonSpecies> onSpeciesTap;

  @override
  State<EvolutionRouteList> createState() => _EvolutionRouteListState();
}

class _EvolutionRouteListState extends State<EvolutionRouteList> {
  final Map<int, int> _selectedRoute = {};

  @override
  Widget build(BuildContext context) {
    final firstRoute = <int, int>{};
    for (var i = 0; i < widget.routes.length; i++) {
      for (final species in widget.routes[i]) {
        firstRoute.putIfAbsent(species.id, () => i);
      }
    }
    return ScrollReveal(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(widget.title,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        const SizedBox(height: 12),
        for (var i = 0; i < widget.routes.length; i++)
          EvolutionRouteCard(
            route: widget.routes[i],
            heroFor: (species) =>
                species.id != widget.currentPokemonId &&
                !widget.heroExcludedIds.contains(species.id) &&
                (_selectedRoute[species.id] ?? firstRoute[species.id]) == i,
            onSpeciesTap: (species) {
              setState(() => _selectedRoute[species.id] = i);
              widget.onSpeciesTap(species);
            },
          ),
      ]),
    ));
  }
}
