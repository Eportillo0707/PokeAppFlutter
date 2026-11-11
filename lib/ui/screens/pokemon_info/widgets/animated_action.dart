import 'package:flutter/material.dart';

class AnimatedAction extends StatefulWidget {
  const AnimatedAction({super.key, required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  State<AnimatedAction> createState() => AnimatedActionState();
}

class AnimatedActionState extends State<AnimatedAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1, end: 1.16), weight: 35),
    TweenSequenceItem(tween: Tween(begin: 1.16, end: 1), weight: 65),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap == null
            ? null
            : () {
                _controller.forward(from: 0);
                widget.onTap!();
              },
        child: widget.child,
      ),
    );
  }
}
