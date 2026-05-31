import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';

class HeaderButtons extends StatelessWidget {
  const HeaderButtons({
    super.key,
    required this.onSearch,
    required this.onFilter,
    required this.onGenerationFilter,
    this.hasGenerationFilter = false,
  });

  final VoidCallback onSearch;
  final VoidCallback onFilter;
  final VoidCallback onGenerationFilter;
  final bool hasGenerationFilter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 350,
        height: 38,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onSearch,
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFF232B4C),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.grey, width: .5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  context.l10n.search,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _HeaderIconButton(
              icon: Icons.tune,
              onPressed: onFilter,
            ),
            const SizedBox(width: 8),
            _HeaderIconButton(
              icon: Icons.catching_pokemon,
              selected: hasGenerationFilter,
              onPressed: onGenerationFilter,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor:
              selected ? const Color(0xFF30385F) : const Color(0xFF232B4C),
          foregroundColor: selected ? const Color(0xFFE8D8FF) : Colors.white,
          side: BorderSide(
            color: selected ? const Color(0xFFE8D8FF) : Colors.grey,
            width: .5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
