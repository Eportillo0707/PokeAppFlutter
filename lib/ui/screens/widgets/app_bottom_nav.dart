import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.index,
    required this.onSelected,
  });

  final int index;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 60,
        color: const Color(0xFF232B4C),
        child: Row(
          children: [
            _BottomTab(
              title: context.l10n.pokemon,
              selected: index == 0,
              onTap: () => onSelected(0),
            ),
            _BottomTab(
              title: context.l10n.favorites,
              selected: index == 1,
              onTap: () => onSelected(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomTab extends StatelessWidget {
  const _BottomTab({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: _textStyle),
            const SizedBox(height: 6),
            _SelectionIndicator(selected: selected),
          ],
        ),
      ),
    );
  }

  TextStyle get _textStyle => TextStyle(
        color: selected ? Colors.white : Colors.grey,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      );
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35,
      height: 7,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE8D8FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }
}
