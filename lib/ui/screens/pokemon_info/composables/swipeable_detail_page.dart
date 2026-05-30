import 'package:flutter/material.dart';

class SwipeableDetailPage extends StatelessWidget {
  const SwipeableDetailPage({
    super.key,
    required this.selectedPage,
    required this.onPageSelected,
    required this.child,
  });

  final int selectedPage;
  final ValueChanged<int> onPageSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -120 && selectedPage == 0) {
          onPageSelected(1);
        } else if (velocity > 120 && selectedPage == 1) {
          onPageSelected(0);
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          final offset = Tween<Offset>(
            begin: Offset(selectedPage == 0 ? -0.08 : 0.08, 0),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offset, child: child),
          );
        },
        child: child,
      ),
    );
  }
}
