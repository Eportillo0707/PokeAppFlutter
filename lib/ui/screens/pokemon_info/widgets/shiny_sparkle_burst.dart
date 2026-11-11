import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/sparkle_painter.dart';

import 'package:flutter/material.dart';

class ShinySparkleBurst extends StatefulWidget {
  const ShinySparkleBurst({
    super.key,
    required this.active,
    required this.child,
  });

  final bool active;
  final Widget child;

  @override
  State<ShinySparkleBurst> createState() => _ShinySparkleBurstState();
}

class _ShinySparkleBurstState extends State<ShinySparkleBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );

  @override
  void didUpdateWidget(covariant ShinySparkleBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: SparklePainter(_controller.value),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
