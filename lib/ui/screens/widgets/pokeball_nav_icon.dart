import 'package:flutter/material.dart';

class PokeballNavIcon extends StatelessWidget {
  const PokeballNavIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    return CustomPaint(
      size: Size.square(theme.size ?? 27),
      painter: _PokeballPainter(theme.color ?? Colors.white),
    );
  }
}

class _PokeballPainter extends CustomPainter {
  const _PokeballPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * .43;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * .09;
    canvas.drawCircle(center, radius, stroke);
    canvas.drawLine(Offset(center.dx - radius, center.dy),
        Offset(center.dx + radius, center.dy), stroke);
    canvas.drawCircle(center, radius * .29, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PokeballPainter oldDelegate) =>
      oldDelegate.color != color;
}
