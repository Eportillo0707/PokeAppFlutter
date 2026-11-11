part of 'move_mobile_list.dart';

extension _MoveFilterControls on _MoveMobileListState {
  Widget _filterControls(
      BuildContext context, List<String> availableTypes, Set<String> methods) {
    final l10n = context.l10n;
    return Theme(
        data: Theme.of(context),
        child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              Row(children: [
                Expanded(
                    child: Wrap(spacing: 8, runSpacing: 6, children: [
                  for (final method in methods)
                    ChoiceChip(
                      selected: _method == method,
                      showCheckmark: false,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      labelStyle: TextStyle(
                          color: _method == method
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface),
                      label: Text(method == 'machine'
                          ? (l10n.isSpanish ? 'MT' : 'TM')
                          : l10n.methodName(method)),
                      onSelected: (_) => _updateState(() {
                        _method = method;
                        _limit = 30;
                      }),
                    ),
                ])),
                IconButton(
                    tooltip: l10n.filterMoves,
                    isSelected: _filters,
                    onPressed: () => _updateState(() => _filters = !_filters),
                    icon: const Icon(Icons.filter_list)),
              ]),
              if (_filters) ...[
                const SizedBox(height: 16),
                _filterFields(context, availableTypes),
                TextButton(
                    onPressed: () => _updateState(() {
                          _type = '';
                          _category = '';
                          _limit = 30;
                        }),
                    child: Text(
                        l10n.isSpanish ? 'Limpiar filtros' : 'Clear filters')),
              ],
            ])));
  }
}
