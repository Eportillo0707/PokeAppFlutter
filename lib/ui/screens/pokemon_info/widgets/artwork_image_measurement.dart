import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

Future<ui.Image> resolveUiImage(ImageProvider provider) {
  final completer = Completer<ui.Image>();
  final stream = provider.resolve(ImageConfiguration.empty);
  late ImageStreamListener listener;
  listener = ImageStreamListener(
    (info, _) {
      stream.removeListener(listener);
      completer.complete(info.image);
    },
    onError: (error, stackTrace) {
      stream.removeListener(listener);
      completer.completeError(error, stackTrace);
    },
  );
  stream.addListener(listener);
  return completer.future;
}

VisibleArtwork? visibleArtworkFromImage(
    ui.Image image, ByteData bytes, double boxSize) {
  final bounds = alphaBounds(bytes, image.width, image.height);
  if (bounds == null) return null;
  final largestSide = image.width > image.height ? image.width : image.height;
  final containScale = boxSize / largestSide;
  final renderedWidth = image.width * containScale;
  final renderedHeight = image.height * containScale;
  final imageLeft = (boxSize - renderedWidth) / 2;
  final imageTop = (boxSize - renderedHeight) / 2;
  final center = Offset(
    imageLeft + bounds.center.dx * containScale,
    imageTop + bounds.center.dy * containScale,
  );
  return VisibleArtwork(
    width: bounds.width * containScale,
    height: bounds.height * containScale,
    centerOffset: center - Offset(boxSize / 2, boxSize / 2),
  );
}

AlphaBounds? alphaBounds(ByteData bytes, int width, int height) {
  var minX = width, minY = height, maxX = -1, maxY = -1;
  final data = bytes.buffer.asUint8List();
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final alpha = data[((y * width + x) * 4) + 3];
      if (alpha <= 8) continue;
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }
  }
  if (maxX < minX || maxY < minY) return null;
  return AlphaBounds(minX: minX, minY: minY, maxX: maxX, maxY: maxY);
}

class AlphaBounds {
  const AlphaBounds({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });

  final int minX;
  final int minY;
  final int maxX;
  final int maxY;

  double get width => (maxX - minX + 1).toDouble();
  double get height => (maxY - minY + 1).toDouble();
  Offset get center => Offset(minX + width / 2, minY + height / 2);
}

class VisibleArtwork {
  const VisibleArtwork({
    required this.width,
    required this.height,
    required this.centerOffset,
  });

  final double width;
  final double height;
  final Offset centerOffset;
}
