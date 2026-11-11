import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/l10n/move_localizations.dart';

class DetailTabs extends StatelessWidget {
  const DetailTabs({
    super.key,
    required this.selectedPage,
    required this.onInfoClick,
    required this.onStatsClick,
    required this.onMovesClick,
  });

  final int selectedPage;
  final VoidCallback onInfoClick;
  final VoidCallback onStatsClick;
  final VoidCallback onMovesClick;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _DetailTabButton(
              icon: Icons.info,
              selected: selectedPage == 0,
              onTap: onInfoClick,
            ),
            _DetailTabButton(
              icon: Icons.bar_chart,
              selected: selectedPage == 1,
              onTap: onStatsClick,
            ),
            Tooltip(
              message: context.l10n.moves,
              child: _DetailTabButton(
                icon: Icons.album_outlined,
                selected: selectedPage == 2,
                onTap: onMovesClick,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTabButton extends StatelessWidget {
  const _DetailTabButton({
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
            size: 26,
            color: selected ? Colors.white : Colors.white60,
          ),
          const SizedBox(height: 6),
          Container(
            width: 36,
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
