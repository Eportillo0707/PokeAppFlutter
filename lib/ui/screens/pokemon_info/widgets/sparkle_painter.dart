import 'dart:math' as math;
import 'package:flutter/material.dart';

class SparklePainter extends CustomPainter {
  const SparklePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1) return;
    final unit = math.min(size.width, size.height);
    final paint = Paint()
      ..color = const Color(0xFFFFE082).withValues(
        alpha: math.sin(progress * math.pi).clamp(0, 1).toDouble(),
      );
    const points = <Offset>[
      Offset(.15, .25),
      Offset(.83, .18),
      Offset(.91, .62),
      Offset(.22, .78),
      Offset(.56, .08),
    ];
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final center = Offset(
        point.dx * size.width + (point.dx - .5) * unit * .12 * progress,
        point.dy * size.height + (point.dy - .5) * unit * .12 * progress,
      );
      final radius =
          unit * (i.isEven ? .045 : .032) * math.sin(progress * math.pi);
      final path = Path()
        ..moveTo(center.dx, center.dy - radius)
        ..lineTo(center.dx + radius * .22, center.dy - radius * .22)
        ..lineTo(center.dx + radius, center.dy)
        ..lineTo(center.dx + radius * .22, center.dy + radius * .22)
        ..lineTo(center.dx, center.dy + radius)
        ..lineTo(center.dx - radius * .22, center.dy + radius * .22)
        ..lineTo(center.dx - radius, center.dy)
        ..lineTo(center.dx - radius * .22, center.dy - radius * .22)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
