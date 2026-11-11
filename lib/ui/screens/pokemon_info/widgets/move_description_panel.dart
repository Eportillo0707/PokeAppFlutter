part of 'move_description_sheet.dart';

extension _MoveDescriptionPanel on _MoveDescriptionSheetState {
  Widget _descriptionPanel(BuildContext context) {
    final l10n = context.l10n;
    return DetailPanel(
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
                      style: const TextStyle(fontSize: 16, height: 1.5)),
                  if (description.game != widget.game ||
                      description.language != l10n.languageCode) ...[
                    const SizedBox(height: 16),
                    Text(
                        '${l10n.isSpanish ? 'Descripción disponible en' : 'Description available in'}: ${l10n.gameName(description.game)} (${description.language.toUpperCase()})',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ]);
          },
        ));
  }
}
