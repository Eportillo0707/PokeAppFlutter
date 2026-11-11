import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/ui/components/type_icons.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';

class MovePill extends StatelessWidget {
  const MovePill(
      {super.key,
      required this.label,
      required this.icon,
      required this.color});
  final String label;
  final Widget icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        width: 128,
        constraints: const BoxConstraints(minHeight: 28),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          SizedBox(width: 18, height: 16, child: icon),
          const SizedBox(width: 6),
          Expanded(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: Colors.white))),
        ]),
      );
}

class MoveTypeBadge extends StatelessWidget {
  const MoveTypeBadge({super.key, required this.type});
  final String type;
  @override
  Widget build(BuildContext context) => MovePill(
        label: context.l10n.pokemonType(type),
        icon: Icon(pokemonTypeIcon(type), size: 16, color: Colors.white),
        color: pokemonTypeColor(type),
      );
}
