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
            DetailPanel(
                title: l10n.description,
                child: FutureBuilder<MoveDescription?>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Column(children: [
                        Text(l10n.loadError),
                        TextButton(
                            onPressed: () => _updateState(() {
                                  _future = _load();
                                }),
                            child: Text(l10n.retry)),
                      ]);
                    }
                    final description = snapshot.data;
                    if (description == null) {
                      return Text(l10n.descriptionUnavailable);
                    }
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(description.text,
                              style:
                                  const TextStyle(fontSize: 16, height: 1.5)),
                          if (description.game != widget.game ||
                              description.language != l10n.languageCode) ...[
                            const SizedBox(height: 16),
                            Text(
                                '${l10n.isSpanish ? 'Descripción disponible en' : 'Description available in'}: ${l10n.gameName(description.game)} (${description.language.toUpperCase()})',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ]);
                  },
                )),
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

extension _MoveDescriptionStats on _MoveDescriptionSheetState {
  Widget _stat(
          BuildContext context, double width, String label, String value) =>
      Container(
        width: width < 300 || MediaQuery.textScalerOf(context).scale(14) > 20
            ? width
            : (width - 24) / 3,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: .16)),
            borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall)
        ]),
      );
}
