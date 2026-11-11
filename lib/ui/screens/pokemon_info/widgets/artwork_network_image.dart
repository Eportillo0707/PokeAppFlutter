import 'package:flutter/material.dart';

class ArtworkNetworkImage extends StatelessWidget {
  const ArtworkNetworkImage({
    super.key,
    required this.url,
    required this.fallbackUrl,
    required this.size,
  });

  final String url;
  final String fallbackUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      url,
      height: size,
      width: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return Image.asset(fallbackUrl, height: size, width: size);
      },
    );
  }
}
