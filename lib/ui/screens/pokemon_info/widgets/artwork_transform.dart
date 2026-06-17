import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/artwork_image_measurement.dart';

class ArtworkTransform {
  const ArtworkTransform({required this.scale, required this.offset});

  final double scale;
  final Offset offset;

  factory ArtworkTransform.match(VisibleArtwork normal, VisibleArtwork shiny) {
    final widthScale = normal.width / shiny.width;
    final heightScale = normal.height / shiny.height;
    final scale = widthScale < heightScale ? widthScale : heightScale;
    return ArtworkTransform(
      scale: scale.clamp(.65, 1.15).toDouble(),
      offset: normal.centerOffset - shiny.centerOffset * scale,
    );
  }
}
