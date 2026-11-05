import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/ui/components/type_badge.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';
part 'team_pokemon_picker_presentation.dart';

class TeamPokemonPicker extends StatefulWidget {
  const TeamPokemonPicker(
      {super.key, required this.api, required this.excluded});
  final PokemonRepository api;
  final Set<int> excluded;
  @override
  State<TeamPokemonPicker> createState() => _TeamPokemonPickerState();
}

class _TeamPokemonPickerState extends State<TeamPokemonPicker> {
  final controller = TextEditingController();
  late Future<List<PokemonItem>> results;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    results = widget.api.getPokemonList(limit: 30);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), search);
  }

  void search() {
    _debounce?.cancel();
    if (!mounted) return;
    setState(() {
      final query = controller.text.trim().toLowerCase();
      results = query.isEmpty
          ? widget.api.getPokemonList(limit: 30)
          : widget.api.searchPokemon(query);
    });
  }

  @override
  Widget build(BuildContext context) => _buildPicker(context);
}

class TeamPokemonImage extends StatelessWidget {
  const TeamPokemonImage({super.key, required this.pokemon, this.size = 48});
  final PokemonItem pokemon;
  final double size;
  @override
  Widget build(BuildContext context) => Image.network(
        pokemon.imageUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, error, stack) => SizedBox(
            width: size,
            height: size,
            child: const Icon(Icons.catching_pokemon)),
      );
}

class TeamPokemonTypes extends StatelessWidget {
  const TeamPokemonTypes({super.key, required this.types});
  final List<String> types;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: LayoutBuilder(builder: (context, constraints) {
          if (types.isEmpty) return const SizedBox.shrink();
          final width =
              ((constraints.maxWidth - (types.length - 1) * 4) / types.length)
                  .clamp(0.0, 76.0);
          return Row(children: [
            for (var i = 0; i < types.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Tooltip(
                  message: context.l10n.pokemonType(types[i]),
                  child: TypeBadgeImage(type: types[i], width: width)),
            ],
          ]);
        }),
      );
}
