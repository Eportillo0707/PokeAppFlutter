import 'package:flutter/material.dart';

class ScrollReveal extends StatefulWidget {
  const ScrollReveal({super.key, required this.child});

  final Widget child;

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal> {
  ScrollPosition? _position;
  bool _visible = false;
  bool _checkedInitialViewport = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (_position != position) {
      _position?.removeListener(_checkVisibility);
      _position = position;
      _position?.addListener(_checkVisibility);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  void _checkVisibility() {
    if (!mounted || _visible) return;
    final box = context.findRenderObject();
    final viewport = Scrollable.maybeOf(context)?.context.findRenderObject();
    if (box is! RenderBox ||
        viewport is! RenderBox ||
        !box.hasSize ||
        !viewport.hasSize) {
      return;
    }
    final top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
    if (!_checkedInitialViewport) {
      final initiallyVisible =
          top < viewport.size.height && top + box.size.height > 0;
      setState(() {
        _checkedInitialViewport = true;
        _visible = initiallyVisible;
      });
      return;
    }
    if (top < viewport.size.height * .68 && top + box.size.height > 0) {
      setState(() => _visible = true);
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_checkVisibility);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final show = !_checkedInitialViewport ||
        _visible ||
        MediaQuery.disableAnimationsOf(context);
    return AnimatedSlide(
      offset: show ? Offset.zero : const Offset(0, .16),
      duration: const Duration(milliseconds: 560),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: show ? 1 : 0,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
