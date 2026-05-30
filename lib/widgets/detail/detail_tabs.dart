import 'package:flutter/material.dart';

class DetailTabs extends StatelessWidget {
  const DetailTabs({
    super.key,
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
        ],
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
