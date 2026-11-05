import 'package:flutter/material.dart';

class MoveLearningBadge extends StatelessWidget {
  const MoveLearningBadge({super.key, required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        backgroundColor: theme.colorScheme.primary.withValues(alpha: .09),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      onPressed: onTap,
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}
