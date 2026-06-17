import 'package:flutter/material.dart';

class EvolutionMethodLabel extends StatelessWidget {
  const EvolutionMethodLabel({
    super.key,
    required this.method,
    required this.itemImageUrl,
  });

  final String method;
  final String? itemImageUrl;

  @override
  Widget build(BuildContext context) {
    final hasItem = itemImageUrl != null && itemImageUrl!.isNotEmpty;
    return SizedBox(
      width: 155,
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF232B4C),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasItem) _EvolutionItemImage(url: itemImageUrl!),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    method,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EvolutionItemImage extends StatelessWidget {
  const _EvolutionItemImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Image.network(
        url,
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
