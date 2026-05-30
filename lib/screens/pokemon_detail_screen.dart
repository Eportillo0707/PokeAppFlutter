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
    final initialColor = pokemonTypeColor(widget.initialPokemon.types.firstOrNull);
    return Scaffold(
      appBar: AppBar(
        title: Text(formatPokemonName(widget.initialPokemon.name)),
        backgroundColor: initialColor,
      ),
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
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _PokemonHero(
                      pokemon: pokemon,
                      onFavorite: () => _toggle(pokemon),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _Description(pokemon: pokemon),
                        const SizedBox(height: 16),
                        _Stats(pokemon: pokemon),
                        const SizedBox(height: 16),
                        _Abilities(pokemon: pokemon),
                        const SizedBox(height: 16),
                        _Evolutions(pokemon: pokemon),
                      ]),
                    ),
                  ),
                ],
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

class _PokemonHero extends StatelessWidget {
  const _PokemonHero({required this.pokemon, required this.onFavorite});

  final PokemonInfo pokemon;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final color = pokemonTypeColor(pokemon.types.firstOrNull);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${pokemon.id.toString().padLeft(3, '0')}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.75),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      formatPokemonName(pokemon.name),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: onFavorite,
                icon: Icon(
                  pokemon.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: pokemon.isFavorite ? Colors.redAccent : Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pokemon.types.map((type) => TypeChip(type: type)).toList(),
          ),
          Center(
            child: Image.network(
              pokemon.toItem().imageUrl,
              height: 240,
              fit: BoxFit.contain,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Spec(label: 'Altura', value: '${pokemon.height / 10} m'),
              _Spec(label: 'Peso', value: '${pokemon.weight / 10} kg'),
              _Spec(label: 'EXP', value: '${pokemon.baseExperience}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(.78))),
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
      title: 'Descripcion',
      child: Text(
        pokemon.description.isEmpty
            ? 'Descripcion no disponible.'
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
    return _Panel(
      title: 'Estadisticas',
      child: Column(
        children: pokemon.stats
            .map(
              (stat) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 96,
                      child: Text(formatPokemonName(stat.name)),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (stat.baseStat / 255).clamp(0, 1).toDouble(),
                        minHeight: 10,
                      ),
                    ),
                    SizedBox(
                      width: 42,
                      child: Text(
                        '${stat.baseStat}',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
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
      title: 'Habilidades',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: pokemon.abilities
            .map(
              (ability) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatPokemonName(ability.name),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    if (ability.flavorText.isNotEmpty)
                      Text(
                        ability.flavorText,
                        style: TextStyle(color: Colors.white.withOpacity(.78)),
                      ),
                  ],
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
      title: 'Evoluciones',
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
                              color: Colors.white.withOpacity(.7),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
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
