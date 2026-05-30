import 'package:flutter/material.dart';

import '../models/pokemon_models.dart';
import '../services/favorites_store.dart';
import '../services/pokeapi_client.dart';
import '../utils/pokemon_formatters.dart';
import '../utils/type_effectiveness.dart';
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
  final detailScrollController = ScrollController();
  int selectedPage = 0;
  bool isPopping = false;

  @override
  void initState() {
    super.initState();
    future = widget.api.getPokemonInfo(widget.initialPokemon.name);
  }

  @override
  void dispose() {
    detailScrollController.dispose();
    super.dispose();
  }

  Future<void> _toggle(PokemonInfo pokemon) async {
    await widget.favorites.toggle(pokemon.toItem());
    setState(
        () => pokemon.isFavorite = widget.favorites.isFavorite(pokemon.id));
  }

  Future<void> _popWithHero() async {
    if (isPopping) return;
    isPopping = true;

    if (detailScrollController.hasClients &&
        detailScrollController.offset > 12) {
      await detailScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _popWithHero();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121422),
        body: FutureBuilder<PokemonInfo>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _HeaderLoading(
                initialPokemon: widget.initialPokemon,
                onBack: _popWithHero,
              );
            }
            if (snapshot.hasError) {
              return ErrorState(
                onRetry: () => setState(
                  () => future =
                      widget.api.getPokemonInfo(widget.initialPokemon.name),
                ),
              );
            }
            final pokemon = snapshot.data!
              ..isFavorite = widget.favorites.isFavorite(snapshot.data!.id);
            return AnimatedBuilder(
              animation: widget.favorites,
              builder: (context, _) {
                pokemon.isFavorite = widget.favorites.isFavorite(pokemon.id);
                return SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: detailScrollController,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  _TopCircle(types: pokemon.types),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: IconButton(
                                      onPressed: _popWithHero,
                                      icon: const Icon(Icons.arrow_back),
                                    ),
                                  ),
                                  Align(
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
                                  Padding(
                                    padding: const EdgeInsets.only(top: 52),
                                    child: _PokemonHero(pokemon: pokemon),
                                  ),
                                ],
                              ),
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
                              _InfoTabs(
                                selectedPage: selectedPage,
                                onInfoClick: () => setState(() {
                                  selectedPage = 0;
                                }),
                                onStatsClick: () => setState(() {
                                  selectedPage = 1;
                                }),
                              ),
                              _InfoPageCard(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onHorizontalDragEnd: (details) {
                                    final velocity =
                                        details.primaryVelocity ?? 0;
                                    if (velocity < -120 && selectedPage == 0) {
                                      setState(() => selectedPage = 1);
                                    } else if (velocity > 120 &&
                                        selectedPage == 1) {
                                      setState(() => selectedPage = 0);
                                    }
                                  },
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 180),
                                    switchInCurve: Curves.easeOut,
                                    switchOutCurve: Curves.easeIn,
                                    transitionBuilder: (child, animation) {
                                      final offset = Tween<Offset>(
                                        begin: Offset(
                                          selectedPage == 0 ? -0.08 : 0.08,
                                          0,
                                        ),
                                        end: Offset.zero,
                                      ).animate(animation);
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: offset,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: selectedPage == 0
                                        ? Column(
                                            key: const ValueKey('info-page'),
                                            children: [
                                              _Description(pokemon: pokemon),
                                              _Specs(pokemon: pokemon),
                                              _Abilities(pokemon: pokemon),
                                              _Evolutions(
                                                pokemon: pokemon,
                                                api: widget.api,
                                                favorites: widget.favorites,
                                              ),
                                              const SizedBox(height: 24),
                                            ],
                                          )
                                        : Column(
                                            key: const ValueKey('stats-page'),
                                            children: [
                                              _Stats(pokemon: pokemon),
                                              _TypesDetails(
                                                effectiveness:
                                                    getDefensiveEffectiveness(
                                                  pokemon.types,
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const _DetailBottomBar(),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DetailBottomBar extends StatelessWidget {
  const _DetailBottomBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 60,
        color: const Color(0xFF232B4C),
        child: const Row(
          children: [
            _DetailBottomTab(title: 'Pokemon', selected: true),
            _DetailBottomTab(title: 'Favorites', selected: false),
          ],
        ),
      ),
    );
  }
}

class _DetailBottomTab extends StatelessWidget {
  const _DetailBottomTab({required this.title, required this.selected});

  final String title;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 35,
            height: 7,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE8D8FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPageCard extends StatelessWidget {
  const _InfoPageCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: .12)),
      ),
      color: const Color(0xFF202339),
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: child,
    );
  }
}

class _HeaderLoading extends StatelessWidget {
  const _HeaderLoading({
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
          _TopCircle(types: initialPokemon.types),
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
  const _InfoTabs({
    required this.selectedPage,
    required this.onInfoClick,
    required this.onStatsClick,
  });

  final int selectedPage;
  final VoidCallback onInfoClick;
  final VoidCallback onStatsClick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 85),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _InfoTabButton(
            icon: Icons.info,
            selected: selectedPage == 0,
            onTap: onInfoClick,
          ),
          _InfoTabButton(
            icon: Icons.bar_chart,
            selected: selectedPage == 1,
            onTap: onStatsClick,
          ),
        ],
      ),
    );
  }
}

class _InfoTabButton extends StatelessWidget {
  const _InfoTabButton({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: selected ? Colors.white : Colors.grey,
          ),
          const SizedBox(height: 6),
          Container(
            width: 50,
            height: 3,
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ],
      ),
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
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: value),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.linear,
                  builder: (context, animatedValue, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: animatedValue,
                        minHeight: 10,
                        backgroundColor: Colors.grey.withValues(alpha: .3),
                        color: Colors.white,
                      ),
                    );
                  },
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
  const _Evolutions({
    required this.pokemon,
    required this.api,
    required this.favorites,
  });

  final PokemonInfo pokemon;
  final PokeApiClient api;
  final FavoritesStore favorites;

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
            title: 'Evolution Chain',
            species: normal,
            showArrows: true,
            api: api,
            favorites: favorites,
          ),
        if (mega.isNotEmpty)
          _EvolutionSection(
            title: 'Mega Evolutions',
            species: mega,
            showArrows: false,
            api: api,
            favorites: favorites,
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
    required this.api,
    required this.favorites,
  });

  final String title;
  final List<PokemonSpecies> species;
  final bool showArrows;
  final PokeApiClient api;
  final FavoritesStore favorites;

  @override
  Widget build(BuildContext context) {
    return _Panel(
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
                child: Text(
                  shouldShowArrow ? '➜' : '',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );
          },
          itemBuilder: (context, index) {
            final item = species[index];
            return _EvolutionItem(
              species: item,
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => PokemonDetailScreen(
                    api: api,
                    favorites: favorites,
                    initialPokemon: PokemonItem(
                      id: item.id,
                      name: item.name,
                      types: const [],
                    ),
                  ),
                ),
              ),
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
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasItem)
              Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Image.network(
                  itemImageUrl!,
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  method,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .75),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypesDetails extends StatelessWidget {
  const _TypesDetails({required this.effectiveness});

  final TypeEffectiveness effectiveness;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TypeGroup(
            title: 'Resistances',
            label: '1/2x From:',
            types: effectiveness.resistantTo),
        _TypeGroup(
            title: null,
            label: '1/4x From:',
            types: effectiveness.veryResistantTo),
        _TypeGroup(
            title: null, label: 'Immunities:', types: effectiveness.immuneTo),
        _TypeGroup(
            title: 'Weaknesses',
            label: '4x From:',
            types: effectiveness.veryWeakTo),
        _TypeGroup(title: null, label: '2x From:', types: effectiveness.weakTo),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _TypeGroup extends StatelessWidget {
  const _TypeGroup({
    required this.title,
    required this.label,
    required this.types,
  });

  final String? title;
  final String label;
  final List<String> types;

  @override
  Widget build(BuildContext context) {
    if (types.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
            ),
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: types
                .map((type) => TypeBadgeImage(type: type, width: 100))
                .toList(),
          ),
        ],
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
