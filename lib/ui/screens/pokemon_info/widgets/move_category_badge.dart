import 'move_pill.dart';
import 'package:flutter/material.dart';
import 'move_category_painter.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';

String moveCategoryName(BuildContext context, String category) =>
    switch (category) {
      'physical' => context.l10n.isSpanish ? 'Físico' : 'Physical',
      'special' => context.l10n.isSpanish ? 'Especial' : 'Special',
      'status' => context.l10n.isSpanish ? 'Estado' : 'Status',
      _ => '—',
    };

class MoveCategoryBadge extends StatelessWidget {
  const MoveCategoryBadge({super.key, required this.category});
  final String category;
  @override
  Widget build(BuildContext context) {
    final color = switch (category) {
      'physical' => const Color(0xFFDD785B),
      'special' => const Color(0xFF657BD5),
      _ => const Color(0xFF747983)
    };
    return MovePill(
        label: moveCategoryName(context, category),
        icon: MoveCategoryIcon(category: category),
        color: color.withValues(alpha: .3));
  }
}

class MoveCategoryIcon extends StatelessWidget {
  const MoveCategoryIcon({super.key, required this.category});
  final String category;
  @override
  Widget build(BuildContext context) {
    if (!const {'physical', 'special', 'status'}.contains(category)) {
      return const SizedBox(width: 32, height: 14);
    }
    return Semantics(
      label: moveCategoryName(context, category),
      image: true,
      child: CustomPaint(
          size: const Size(28, 22), painter: CategoryPainter(category)),
    );
  }
}
