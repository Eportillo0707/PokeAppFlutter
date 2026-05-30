import 'package:flutter/material.dart';

import '../models/pokemon_models.dart';
import '../utils/pokemon_formatters.dart';

class PokemonCard extends StatelessWidget {
  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.onTap,
  });

  final PokemonItem pokemon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        color: const Color(0xFF202339),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: .12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'pokemon-image-${pokemon.name}',
                child: Image.network(
                  pokemon.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox(height: 100),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formatPokemonName(pokemon.name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: pokemon.types
                    .map((type) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: TypeBadgeImage(type: type, width: 72),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TypeBadgeImage extends StatelessWidget {
  const TypeBadgeImage({super.key, required this.type, this.width = 100});

  final String type;
  final double width;

  static const _files = {
    'grass': 'grasssv.png',
    'poison': 'poisonsv.png',
    'fire': 'firesv.png',
    'water': 'watersv.png',
    'bug': 'bugsv.png',
    'normal': 'normalsv.png',
    'electric': 'electricsv.png',
    'ground': 'groundsv.png',
    'fairy': 'fairysv.png',
    'fighting': 'fightingsv.png',
    'psychic': 'psychicsv.png',
    'rock': 'rocksv.png',
    'ghost': 'ghostsv.png',
    'ice': 'iceicsv.png',
    'dragon': 'dragonsv.png',
    'dark': 'darksv.png',
    'steel': 'steelsv.png',
    'flying': 'flyingsv.png',
  };

  @override
  Widget build(BuildContext context) {
    final file = _files[type.toLowerCase()];
    if (file == null) return TypeChip(type: type, compact: true);
    return Image.asset(
      'assets/icons/$file',
      width: width,
      height: width * .38,
      fit: BoxFit.contain,
    );
  }
}

class TypeChip extends StatelessWidget {
  const TypeChip({super.key, required this.type, this.compact = false});

  final String type;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 7,
      ),
      decoration: BoxDecoration(
        color: pokemonTypeColor(type),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        formatPokemonName(type),
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 11 : 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            const Text(
              'No se pudo cargar la informacion.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
