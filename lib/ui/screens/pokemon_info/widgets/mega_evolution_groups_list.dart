import 'package:flutter/material.dart';
import 'scroll_reveal.dart';

class MegaEvolutionGroupsList extends StatelessWidget {
  const MegaEvolutionGroupsList(
      {super.key, required this.title, required this.groups});

  final String title;
  final List<Widget> groups;

  @override
  Widget build(BuildContext context) => ScrollReveal(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 12),
            for (var i = 0; i < groups.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                color: Theme.of(context).colorScheme.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: .16)),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(16), child: groups[i]),
              ),
            ],
          ]),
        ),
      );
}
