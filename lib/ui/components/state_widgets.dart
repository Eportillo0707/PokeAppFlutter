import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.size = 54});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(child: PokeballLoader(size: size));
  }
}

class PokeballLoader extends StatefulWidget {
  const PokeballLoader({super.key, this.size = 54});

  final double size;

  @override
  State<PokeballLoader> createState() => _PokeballLoaderState();
}

class _PokeballLoaderState extends State<PokeballLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: controller,
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: const _PokeballPainter(),
      ),
    );
  }
}

class _PokeballPainter extends CustomPainter {
  const _PokeballPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final stroke = size.width * .07;
    final buttonRadius = size.width * .14;
    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final topPaint = Paint()
      ..color = const Color(0xFFE93434)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = const Color(0xFF151827)
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke;
    final buttonPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: .18)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        center.translate(0, size.width * .05), radius, shadowPaint);
    canvas.drawCircle(center, radius - stroke / 2, outerPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - stroke / 2),
      3.14159,
      3.14159,
      true,
      topPaint,
    );
    canvas.drawCircle(center, radius - stroke / 2, linePaint);
    canvas.drawLine(
      Offset(stroke / 2, radius),
      Offset(size.width - stroke / 2, radius),
      linePaint,
    );
    canvas.drawCircle(center, buttonRadius + stroke / 1.7, linePaint);
    canvas.drawCircle(center, buttonRadius, buttonPaint);
    canvas.drawCircle(center, buttonRadius, linePaint);
  }

  @override
  bool shouldRepaint(covariant _PokeballPainter oldDelegate) => false;
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(
              context.l10n.loadError,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
