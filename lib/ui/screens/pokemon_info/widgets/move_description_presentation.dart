part of 'move_description_sheet.dart';

extension _MoveDescriptionPresentation on _MoveDescriptionSheetState {
  Widget _buildDescription(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<MoveBattleInfo?>(
                future: _battle,
                builder: (context, snapshot) {
                  final info = snapshot.data;
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(info?.name ?? formatPokemonName(widget.move),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text('Pokémon ${l10n.gameName(widget.game)}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall),
                        if (snapshot.connectionState != ConnectionState.done)
                          const LinearProgressIndicator(),
                        if (snapshot.hasError)
                          TextButton(
                              onPressed: () => _updateState(() {
                                    _battle = widget.loadBattleInfo?.call(
                                        widget.move, widget.game, _language!);
                                  }),
                              child: Text(l10n.retry)),
                        if (info != null) ...[
                          if (info.generation != null)
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                    '${l10n.isSpanish ? 'Introducido en la generación' : 'Introduced in generation'} ${info.generation!.replaceFirst('generation-', '').toUpperCase()}',
                                    textAlign: TextAlign.center)),
                          const SizedBox(height: 16),
                          Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              runSpacing: 10,
                              children: [
                                MoveTypeBadge(type: info.type),
                                MoveCategoryBadge(category: info.category)
                              ]),
                          const SizedBox(height: 20),
                          LayoutBuilder(
                              builder: (context, constraints) =>
                                  Wrap(spacing: 12, runSpacing: 12, children: [
                                    _stat(
                                        context,
                                        constraints.maxWidth,
                                        l10n.isSpanish ? 'Potencia' : 'Power',
                                        info.power == null || info.power == 0
                                            ? '—'
                                            : '${info.power}'),
                                    _stat(context, constraints.maxWidth, 'PP',
                                        '${info.pp ?? '—'}'),
                                    _stat(
                                        context,
                                        constraints.maxWidth,
                                        l10n.isSpanish
                                            ? 'Precisión'
                                            : 'Accuracy',
                                        info.accuracy == null
                                            ? '—'
                                            : '${info.accuracy}%'),
                                  ])),
                          const SizedBox(height: 24),
                        ],
                      ]);
                }),
            const SizedBox(height: 8),
            _descriptionPanel(context),
            const SizedBox(height: 24),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.isSpanish ? 'Cerrar' : 'Close')),
          ],
        ),
      ),
    );
  }
}
