import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';
import 'detail_card.dart';

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
    final normal = pokemon.evolutionChain
        .where((item) => !item.name.toLowerCase().contains('-mega'))
        .toList();
    final mega = pokemon.megaEvolutions.isNotEmpty
        ? pokemon.megaEvolutions
        : pokemon.evolutionChain
            .where((item) => item.name.toLowerCase().contains('-mega'))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (normal.isNotEmpty)
          _EvolutionSection(
            title: context.l10n.evolutionChain,
            species: normal,
            showArrows: true,
            onSpeciesTap: onSpeciesTap,
          ),
        if (mega.isNotEmpty)
          _EvolutionSection(
            title: context.l10n.megaEvolutions,
            species: mega,
            showArrows: false,
            onSpeciesTap: onSpeciesTap,
          ),
      ],
    );
  }
}

class _EvolutionSection extends StatelessWidget {
  const _EvolutionSection({
    required this.title,
    required this.species,
    required this.showArrows,
    required this.onSpeciesTap,
  });

  final String title;
  final List<PokemonSpecies> species;
  final bool showArrows;
  final ValueChanged<PokemonSpecies> onSpeciesTap;

  @override
  Widget build(BuildContext context) {
    return DetailPanel(
      title: title,
      child: SizedBox(
        height: 190,
        child: ListView.separated(
          padding: const EdgeInsets.only(right: 32),
          scrollDirection: Axis.horizontal,
          itemCount: species.length,
          separatorBuilder: (context, index) {
            final current = species[index + 1];
            final previous = species[index];
            final shouldShowArrow =
                showArrows && current.evolvesFromSpeciesId == previous.id;
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.arrow_forward,
                  color: shouldShowArrow ? Colors.white : Colors.transparent,
                  size: 32,
                ),
              ),
            );
          },
          itemBuilder: (context, index) {
            final item = species[index];
            return _EvolutionItem(
              species: item,
              onTap: () => onSpeciesTap(item),
            );
          },
        ),
      ),
    );
  }
}

class _EvolutionItem extends StatelessWidget {
  const _EvolutionItem({
    required this.species,
    required this.onTap,
  });

  final PokemonSpecies species;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 155,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Image.network(species.imageUrl, width: 115, height: 115),
            Text(
              formatPokemonName(species.name),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                height: 1.05,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (species.evolutionMethod != null)
              _EvolutionMethodLabel(
                method: species.evolutionMethod!,
                itemImageUrl: species.evolutionItemImageUrl,
              ),
          ],
        ),
      ),
    );
  }
}

class _EvolutionMethodLabel extends StatelessWidget {
  const _EvolutionMethodLabel({
    required this.method,
    required this.itemImageUrl,
  });

  final String method;
  final String? itemImageUrl;

  @override
  Widget build(BuildContext context) {
    final hasItem = itemImageUrl != null && itemImageUrl!.isNotEmpty;
    return SizedBox(
      width: 155,
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF232B4C),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasItem)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Image.network(
                    itemImageUrl!,
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    method,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
