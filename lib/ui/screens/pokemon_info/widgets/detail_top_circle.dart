import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';

class DetailTopCircle extends StatelessWidget {
  const DetailTopCircle({
    super.key,
    required this.types,
    this.maxWidth = 720,
    this.maxScale = 1.45,
  });

  const DetailTopCircle.compact({super.key, required this.types})
      : maxWidth = 430,
        maxScale = 1;

  final List<String> types;
  final double maxWidth;
  final double maxScale;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = constraints.maxWidth.clamp(0.0, maxWidth);
          final scale = (contentWidth / 430).clamp(1.0, maxScale);
          return SizedBox(
            height: 325 * scale,
            width: contentWidth,
            child: ClipRect(
              child: CustomPaint(
                painter: _DetailTopCirclePainter(
                  radius: 300 * scale,
                  colors: [
                    pokemonTypeColor(types.firstOrNull),
                    pokemonTypeColor(
                      types.length > 1 ? types[1] : types.firstOrNull,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailTopCirclePainter extends CustomPainter {
  const _DetailTopCirclePainter({required this.colors, required this.radius});

  final List<Color> colors;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, 0),
      radius: radius,
    );
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: colors,
      ).createShader(rect);
    canvas.drawCircle(Offset(size.width / 2, 0), radius, paint);
  }

  @override
  bool shouldRepaint(covariant _DetailTopCirclePainter oldDelegate) {
    return oldDelegate.colors != colors || oldDelegate.radius != radius;
  }
}
