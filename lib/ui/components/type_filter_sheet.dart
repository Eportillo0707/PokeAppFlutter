import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';
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
    return _TypeBadgePicker(onSelected: onSelected);
  }
}

class _TypeBadgePicker extends StatelessWidget {
  const _TypeBadgePicker({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF232B4C)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8D8FF),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                context.l10n.selectType,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              GridView.builder(
                shrinkWrap: true,
                itemCount: pokemonTypes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.85,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final type = pokemonTypes[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => onSelected(type),
                    child: Center(
                      child: TypeBadgeImage(type: type, width: 108),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
