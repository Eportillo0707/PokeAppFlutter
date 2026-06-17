import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/artwork_image_measurement.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/artwork_network_image.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/widgets/artwork_transform.dart';

class NormalizedPokemonArtwork extends StatefulWidget {
  const NormalizedPokemonArtwork({
    super.key,
    required this.normalUrl,
    required this.imageUrl,
    required this.size,
  });

  final String normalUrl;
  final String imageUrl;
  final double size;

  @override
  State<NormalizedPokemonArtwork> createState() =>
      _NormalizedPokemonArtworkState();
}

class _NormalizedPokemonArtworkState extends State<NormalizedPokemonArtwork> {
  ArtworkTransform? _transform;
  String? _measuredKey;

  @override
  void initState() {
    super.initState();
    _loadTransform();
  }

  @override
  void didUpdateWidget(covariant NormalizedPokemonArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.normalUrl != widget.normalUrl ||
        oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.size != widget.size) {
      _loadTransform();
    }
  }

  Future<void> _loadTransform() async {
    final key = '${widget.normalUrl}|${widget.imageUrl}|${widget.size}';
    _measuredKey = key;
    if (widget.normalUrl == widget.imageUrl) {
      if (mounted) setState(() => _transform = null);
      return;
    }
    try {
      final normal = await _measureImage(widget.normalUrl);
      final shiny = await _measureImage(widget.imageUrl);
      if (!mounted || _measuredKey != key || normal == null || shiny == null) {
        return;
      }
      setState(() => _transform = ArtworkTransform.match(normal, shiny));
    } catch (_) {
      if (mounted && _measuredKey == key) setState(() => _transform = null);
    }
  }

  Future<VisibleArtwork?> _measureImage(String url) async {
    final image = await resolveUiImage(NetworkImage(url));
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (bytes == null) return null;
    return visibleArtworkFromImage(image, bytes, widget.size);
  }

  @override
  Widget build(BuildContext context) {
    final transform = _transform;
    final waiting = widget.normalUrl != widget.imageUrl && transform == null;
    final visibleUrl = waiting ? widget.normalUrl : widget.imageUrl;
    Widget image = ArtworkNetworkImage(
      url: visibleUrl,
      fallbackUrl: widget.normalUrl,
      size: widget.size,
    );
    if (transform != null) {
      image = Transform.translate(
        offset: transform.offset,
        child: Transform.scale(scale: transform.scale, child: image),
      );
    }
    return ClipRect(child: image);
  }
}
