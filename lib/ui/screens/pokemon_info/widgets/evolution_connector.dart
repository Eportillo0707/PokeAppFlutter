import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';

class EvolutionConnector extends StatelessWidget {
  const EvolutionConnector(
      {super.key,
      required this.target,
      required this.width,
      this.reverse = false,
      this.showDetails = true,
      this.mega = false,
      this.stoneAsset});

  final PokemonSpecies target;
  final double width;
  final bool reverse;
  final bool showDetails;
  final bool mega;
  final String? stoneAsset;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(reverse ? Icons.arrow_back : Icons.arrow_forward,
              size: 20, color: Theme.of(context).colorScheme.primary),
          if (mega)
            stoneAsset == null
                ? CircleAvatar(
                    radius: 10,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.diamond,
                        size: 13, color: Colors.white),
                  )
                : Image.asset(stoneAsset!,
                    width: 25, height: 25, filterQuality: FilterQuality.none),
          if (target.evolutionItemImageUrl case final url?)
            if (showDetails)
              SizedBox(
                  width: 22,
                  height: 22,
                  child: url.startsWith('http')
                      ? Image.network(url,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink())
                      : Image.asset(url,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox.shrink())),
          if (target.evolutionMethod case final method?)
            if (showDetails)
              Text(method,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 10, height: 1.1, fontWeight: FontWeight.w600)),
        ]),
      );
}
