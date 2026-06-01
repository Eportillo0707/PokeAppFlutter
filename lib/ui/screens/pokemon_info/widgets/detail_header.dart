import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/ui/components/pokemon_widgets.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';

class DetailHeaderLoading extends StatelessWidget {
  const DetailHeaderLoading({
    super.key,
    required this.initialPokemon,
    required this.onBack,
  });

  final PokemonItem initialPokemon;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          DetailTopCircle(types: initialPokemon.types),
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 52),
            child: Column(
              children: [
                Hero(
                  tag: 'pokemon-image-${initialPokemon.name}',
                  transitionOnUserGestures: true,
                  child: Image.network(
                    initialPokemon.imageUrl,
                    height: 315,
                    width: 315,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                const LoadingState(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.pokemon,
    required this.onBack,
    required this.onFavorite,
    required this.onPlayCry,
  });

  final PokemonInfo pokemon;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final VoidCallback onPlayCry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        DetailTopCircle(types: pokemon.types),
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              children: [
                IconButton(
                  onPressed: onFavorite,
                  icon: Icon(
                    pokemon.isFavorite ? Icons.star : Icons.star_border,
                    size: 34,
                    color: pokemon.isFavorite
                        ? const Color(0xFFFFD54F)
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                _CryButton(
                  enabled: pokemon.cryUrl != null && pokemon.cryUrl!.isNotEmpty,
                  color: pokemonTypeColor(pokemon.types.firstOrNull),
                  onTap: onPlayCry,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 52),
          child: PokemonDetailHero(pokemon: pokemon),
        ),
      ],
    );
  }
}

class _CryButton extends StatelessWidget {
  const _CryButton({
    required this.enabled,
    required this.color,
    required this.onTap,
  });

  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? color : Colors.grey,
      shape: const CircleBorder(),
      elevation: 5,
      shadowColor: color.withValues(alpha: .45),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            Icons.volume_up,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class DetailTopCircle extends StatelessWidget {
  const DetailTopCircle({super.key, required this.types});

  final List<String> types;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 325,
      width: double.infinity,
      child: CustomPaint(
        painter: _DetailTopCirclePainter(
          colors: [
            pokemonTypeColor(types.firstOrNull),
            pokemonTypeColor(types.length > 1 ? types[1] : types.firstOrNull),
          ],
        ),
      ),
    );
  }
}

class _DetailTopCirclePainter extends CustomPainter {
  const _DetailTopCirclePainter({required this.colors});

  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, 0),
      radius: 300,
    );
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: colors,
      ).createShader(rect);
    canvas.drawCircle(Offset(size.width / 2, 0), 300, paint);
  }

  @override
  bool shouldRepaint(covariant _DetailTopCirclePainter oldDelegate) =>
      oldDelegate.colors != colors;
}

class PokemonDetailHero extends StatelessWidget {
  const PokemonDetailHero({super.key, required this.pokemon});

  final PokemonInfo pokemon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Hero(
            tag: 'pokemon-image-${pokemon.name}',
            transitionOnUserGestures: true,
            child: Image.network(
              pokemon.toItem().imageUrl,
              height: 315,
              width: 315,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Text(
                '#${pokemon.id.toString().padLeft(3, '0')}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .68),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatPokemonName(pokemon.name),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PokemonDetailTypeBadges extends StatelessWidget {
  const PokemonDetailTypeBadges({super.key, required this.types});

  final List<String> types;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: types
            .map(
              (type) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TypeBadgeImage(type: type, width: 150),
              ),
            )
            .toList(),
      ),
    );
  }
}
