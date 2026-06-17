part of 'state_widgets.dart';

class _PokeballPainter extends CustomPainter {
  const _PokeballPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final stroke = size.width * .07;
    final buttonRadius = size.width * .14;
    final linePaint = Paint()
      ..color = const Color(0xFF151827)
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(
      center.translate(0, size.width * .05),
      radius,
      Paint()..color = Colors.black.withValues(alpha: .18),
    );
    canvas.drawCircle(
        center, radius - stroke / 2, Paint()..color = Colors.white);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - stroke / 2),
      3.14159,
      3.14159,
      true,
      Paint()..color = const Color(0xFFE93434),
    );
    canvas.drawCircle(center, radius - stroke / 2, linePaint);
    canvas.drawLine(Offset(stroke / 2, radius),
        Offset(size.width - stroke / 2, radius), linePaint);
    canvas.drawCircle(center, buttonRadius + stroke / 1.7, linePaint);
    canvas.drawCircle(center, buttonRadius, Paint()..color = Colors.white);
    canvas.drawCircle(center, buttonRadius, linePaint);
  }

  @override
  bool shouldRepaint(covariant _PokeballPainter oldDelegate) => false;
}
