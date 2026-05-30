import 'package:flutter/material.dart';

import '../../utils/pokemon_formatters.dart';
import 'type_badge.dart';

class TypePickerSheet extends StatelessWidget {
  const TypePickerSheet({
    super.key,
    required this.onSelected,
    this.useImages = false,
  });

  final ValueChanged<String> onSelected;
  final bool useImages;

  @override
  Widget build(BuildContext context) {
    if (useImages) {
      return _ImageTypePicker(onSelected: onSelected);
    }
    return _ChipTypePicker(onSelected: onSelected);
  }
}

class _ChipTypePicker extends StatelessWidget {
  const _ChipTypePicker({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: pokemonTypes
              .map(
                (type) => ActionChip(
                  backgroundColor: pokemonTypeColor(type),
                  label: Text(formatPokemonName(type)),
                  onPressed: () => onSelected(type),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ImageTypePicker extends StatelessWidget {
  const _ImageTypePicker({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select a Type',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 15),
            GridView.builder(
              shrinkWrap: true,
              itemCount: pokemonTypes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final type = pokemonTypes[index];
                return IconButton(
                  onPressed: () => onSelected(type),
                  icon: TypeBadgeImage(type: type, width: 78),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
