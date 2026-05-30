import 'package:flutter/material.dart';

import '../models/pokemon_models.dart';
import '../services/favorites_store.dart';
import '../services/pokeapi_client.dart';
import '../utils/pokemon_formatters.dart';
import '../widgets/pokemon_widgets.dart';

class PokemonDetailScreen extends StatefulWidget {
  const PokemonDetailScreen({
    super.key,
    required this.api,
    required this.favorites,
    required this.initialPokemon,
  });

  final PokeApiClient api;
  final FavoritesStore favorites;
  final PokemonItem initialPokemon;

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  late Future<PokemonInfo> future;

  @override
  void initState() {
    super.initState();
    future = widget.api.getPokemonInfo(widget.initialPokemon.name);
  }

  Future<void> _toggle(PokemonInfo pokemon) async {
    await widget.favorites.toggle(pokemon.toItem());
    setState(() => pokemon.isFavorite = widget.favorites.isFavorite(pokemon.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121422),
      body: FutureBuilder<PokemonInfo>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _HeaderLoading(initialPokemon: widget.initialPokemon);
          }
          if (snapshot.hasError) {
            return ErrorState(
              onRetry: () => setState(
                () => future = widget.api.getPokemonInfo(widget.initialPokemon.name),
              ),
            );
          }
          final pokemon = snapshot.data!
            ..isFavorite = widget.favorites.isFavorite(snapshot.data!.id);
          return AnimatedBuilder(
            animation: widget.favorites,
            builder: (context, _) {
              pokemon.isFavorite = widget.favorites.isFavorite(pokemon.id);
              return DefaultTabController(
                length: 2,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Stack(
                        children: [
                          _TopCircle(types: pokemon.types),
                          SafeArea(
                            bottom: false,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                            ),
                          ),
                          SafeArea(
                            bottom: false,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: IconButton(
                                  onPressed: () => _toggle(pokemon),
                                  icon: Icon(
                                    pokemon.isFavorite
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 34,
                                    color: pokemon.isFavorite
                                        ? const Color(0xFFFFD54F)
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 52),
                            child: _PokemonHero(pokemon: pokemon),
                          ),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: pokemon.types
                                  .map(
                                    (type) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: TypeBadgeImage(
                                        type: type,
                                        width: 150,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const _InfoTabs(),
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: SizedBox(
                        height: 680,
                        child: TabBarView(
                          children: [
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  _Description(pokemon: pokemon),
                                  _Specs(pokemon: pokemon),
                                  _Abilities(pokemon: pokemon),
                                  _Evolutions(pokemon: pokemon),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                            SingleChildScrollView(
                              child: _Stats(pokemon: pokemon),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HeaderLoading extends StatelessWidget {
  const _HeaderLoading({required this.initialPokemon});

  final PokemonItem initialPokemon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Image.network(initialPokemon.imageUrl, height: 220),
        const SizedBox(height: 24),
        const LoadingState(),
      ],
    );
  }
}

class _TopCircle extends StatelessWidget {
  const _TopCircle({required this.types});

  final List<String> types;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 325,
      width: double.infinity,
      child: CustomPaint(
        painter: _TopCirclePainter(
          colors: [
            pokemonTypeColor(types.firstOrNull),
            pokemonTypeColor(types.length > 1 ? types[1] : types.firstOrNull),
          ],
        ),
      ),
    );
  }
}

class _TopCirclePainter extends CustomPainter {
  const _TopCirclePainter({required this.colors});

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
  bool shouldRepaint(covariant _TopCirclePainter oldDelegate) =>
      oldDelegate.colors != colors;
}

class _PokemonHero extends StatelessWidget {
  const _PokemonHero({required this.pokemon});

  final PokemonInfo pokemon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(
          pokemon.toItem().imageUrl,
          height: 315,
          width: 315,
          fit: BoxFit.contain,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FittedBox(
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
        ),
      ],
    );
  }
}

class _InfoTabs extends StatelessWidget {
  const _InfoTabs();

  @override
  Widget build(BuildContext context) {
    return const TabBar(
      indicatorColor: Colors.white,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      tabs: [
        Tab(icon: Icon(Icons.info, size: 40)),
        Tab(icon: Icon(Icons.bar_chart, size: 40)),
      ],
    );
  }
}

class _Specs extends StatelessWidget {
  const _Specs({required this.pokemon});

  final PokemonInfo pokemon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SpecColumn(label: 'Height', value: '${pokemon.height / 10} m'),
          const SizedBox(width: 80),
          Container(width: 1, height: 60, color: Colors.white),
          const SizedBox(width: 30),
          _SpecColumn(label: 'Weight', value: '${pokemon.weight / 10} kg'),
        ],
      ),
    );
  }
}

class _SpecColumn extends StatelessWidget {
  const _SpecColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.pokemon});

  final PokemonInfo pokemon;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Description',
      child: Text(
        pokemon.description.isEmpty
            ? 'Description unavailable.'
            : pokemon.description,
        style: const TextStyle(height: 1.4),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.pokemon});

  final PokemonInfo pokemon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      child: Column(
        children: pokemon.stats.map((stat) {
          final value = (stat.baseStat / 255).clamp(0, 1).toDouble();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stat.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${stat.baseStat}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 10,
                    backgroundColor: Colors.grey.withValues(alpha: .3),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Abilities extends StatelessWidget {
  const _Abilities({required this.pokemon});

  final PokemonInfo pokemon;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Abilities',
      child: Wrap(
        spacing: 5,
        runSpacing: 8,
        children: pokemon.abilities
            .map(
              (ability) => TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF232B4C),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: const Color(0xFF232B4C),
                  builder: (_) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatPokemonName(ability.name),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          ability.flavorText,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                child: Text(
                  formatPokemonName(ability.name),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Evolutions extends StatelessWidget {
  const _Evolutions({required this.pokemon});

  final PokemonInfo pokemon;

  @override
  Widget build(BuildContext context) {
    final species = pokemon.evolutionChain;
    return _Panel(
      title: 'Evolutions',
      child: species.isEmpty
          ? const Text('Sin evoluciones registradas.')
          : SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: species.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = species[index];
                  return SizedBox(
                    width: 116,
                    child: Column(
                      children: [
                        Image.network(item.imageUrl, height: 88),
                        Text(
                          formatPokemonName(item.name),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        if (item.evolutionMethod != null)
                          Text(
                            item.evolutionMethod!,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .7),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
