import 'package:flutter/material.dart';

class DetailRoundActionButton extends StatelessWidget {
  const DetailRoundActionButton({
    super.key,
    required this.enabled,
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.elevation = 5,
  });

  final bool enabled;
  final Color color;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? color : Colors.grey,
      shape: const CircleBorder(),
      elevation: enabled ? elevation : 0,
      shadowColor: color.withValues(alpha: .45),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }
}
