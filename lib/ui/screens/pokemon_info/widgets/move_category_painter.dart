import 'package:flutter/material.dart';

// Vector interpretations of the familiar Pokémon category silhouettes.
// Paths use a 28 × 22 coordinate system and remain crisp at any device density.
class CategoryPainter extends CustomPainter {
  const CategoryPainter(this.category);
  final String category;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 28, size.height / 22);
    final stroke = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeJoin = StrokeJoin.round;
    switch (category) {
      case 'physical':
        final burst = Path()
          ..moveTo(3, 4)
          ..lineTo(10, 6)
          ..lineTo(12, 1)
          ..lineTo(16, 6)
          ..lineTo(24, 2)
          ..lineTo(21, 9)
          ..lineTo(27, 12)
          ..lineTo(20, 14)
          ..lineTo(22, 21)
          ..lineTo(15, 17)
          ..lineTo(10, 21)
          ..lineTo(9, 15)
          ..lineTo(1, 17)
          ..lineTo(5, 11)
          ..lineTo(3, 4)
          ..close();
        canvas.drawPath(
            burst,
            Paint()
              ..color = const Color(0xFFFFD373)
              ..isAntiAlias = true);
        canvas.drawPath(burst, stroke..color = const Color(0xFFB84629));
        break;
      case 'special':
        canvas.translate(14, 11);
        canvas.rotate(-.28);
        stroke.color = const Color(0xFF9DAEFF);
        for (final rect in [
          const Rect.fromLTWH(-12, -8, 24, 16),
          const Rect.fromLTWH(-8, -5, 16, 10),
          const Rect.fromLTWH(-3.5, -2, 7, 4),
        ]) {
          canvas.drawOval(rect, stroke);
        }
        break;
      case 'status':
        canvas.translate(14, 11);
        canvas.rotate(-.35);
        const oval = Rect.fromLTWH(-11, -7, 22, 14);
        canvas.drawOval(
            oval,
            Paint()
              ..color = const Color(0xFFE7E8EE)
              ..isAntiAlias = true);
        final half = Path()
          ..moveTo(0, -7)
          ..cubicTo(6, -6, 6, -1, 0, 0)
          ..cubicTo(-6, 1, -6, 6, 0, 7)
          ..cubicTo(15, 7, 15, -7, 0, -7)
          ..close();
        canvas.drawPath(
            half,
            Paint()
              ..color = const Color(0xFF747983)
              ..isAntiAlias = true);
        canvas.drawOval(oval, stroke..color = const Color(0xFFC8CBD4));
        break;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CategoryPainter oldDelegate) =>
      oldDelegate.category != category;
}
