import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';

part 'app_bottom_nav_tabs.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.index,
    required this.onSelected,
    this.showSettings = false,
  });

  final int index;
  final ValueChanged<int> onSelected;
  final bool showSettings;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF232B4C),
        border:
            Border(top: BorderSide(color: Colors.white.withValues(alpha: .22))),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: .25),
              blurRadius: 16,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _BottomTab(
                title: 'Pokédex',
                selected: index == 0,
                onTap: () => onSelected(0),
              ),
              _BottomTab(
                title: context.l10n.favorites,
                selected: index == 1,
                onTap: () => onSelected(1),
              ),
              _BottomTab(
                title: context.l10n.isSpanish ? 'Equipos' : 'Teams',
                selected: index == 2,
                onTap: () => onSelected(2),
              ),
              if (showSettings) _BottomTab(
                title: context.l10n.isSpanish ? 'Ajustes' : 'Settings',
                selected: index == 3,
                onTap: () => onSelected(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
