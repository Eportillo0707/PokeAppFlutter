import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_move.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/l10n/move_localizations.dart';
import 'move_learning_badge.dart';

class MoveMachineLabel extends StatefulWidget {
  const MoveMachineLabel(
      {super.key,
      required this.move,
      required this.game,
      required this.load,
      this.onTap});

  final String move;
  final String game;
  final MoveMachineLoader load;
  final VoidCallback? onTap;

  @override
  State<MoveMachineLabel> createState() => _MoveMachineLabelState();
}

class _MoveMachineLabelState extends State<MoveMachineLabel> {
  late Future<List<String>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.load(widget.move, widget.game);
  }

  @override
  void didUpdateWidget(covariant MoveMachineLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.move != widget.move || oldWidget.game != widget.game) {
      _future = widget.load(widget.move, widget.game);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = TextStyle(
        fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant);
    return FutureBuilder<List<String>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Text(
              l10n.isSpanish ? 'Consultando máquina…' : 'Checking machine…',
              style: style);
        }
        if (snapshot.hasError) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    l10n.isSpanish
                        ? 'Por máquina · Sin verificar'
                        : 'By machine · Unverified',
                    style: style),
                InkWell(
                  onTap: () => setState(() {
                    _future = widget.load(widget.move, widget.game);
                  }),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(l10n.retry,
                        style: style.copyWith(
                            color: Theme.of(context).colorScheme.primary)),
                  ),
                ),
              ]);
        }
        final items = snapshot.data ?? [];
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items.isEmpty
              ? [
                  MoveLearningBadge(
                    label: l10n.methodName('machine'),
                    onTap: widget.onTap,
                  )
                ]
              : items
                  .map((item) => MoveLearningBadge(
                        label: l10n.machineCode(item),
                        onTap: widget.onTap,
                      ))
                  .toList(),
        );
      },
    );
  }
}
