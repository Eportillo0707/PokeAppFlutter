part of 'move_mobile_list.dart';

extension _MoveFilterFields on _MoveMobileListState {
  Widget _filterFields(BuildContext context, List<String> availableTypes) {
    final l10n = context.l10n;
    return LayoutBuilder(builder: (context, constraints) {
      final typeField = DropdownButtonFormField<String>(
          key: ValueKey('type-$_type'),
          menuMaxHeight: 260,
          borderRadius: BorderRadius.circular(16),
          initialValue: _type,
          isExpanded: true,
          decoration:
              InputDecoration(labelText: l10n.isSpanish ? 'Tipo' : 'Type'),
          items: [
            DropdownMenuItem(
                value: '', child: Text(l10n.isSpanish ? 'Todos' : 'All')),
            ...availableTypes.map((t) =>
                DropdownMenuItem(value: t, child: MoveTypeBadge(type: t)))
          ],
          onChanged: (value) => _updateState(() {
                _type = value ?? '';
                _limit = 30;
              }));
      final categoryField = DropdownButtonFormField<String>(
          key: ValueKey('category-$_category'),
          menuMaxHeight: 240,
          borderRadius: BorderRadius.circular(16),
          initialValue: _category,
          isExpanded: true,
          decoration: InputDecoration(
              labelText: l10n.isSpanish ? 'Categoría' : 'Category'),
          items: [
            DropdownMenuItem(
                value: '', child: Text(l10n.isSpanish ? 'Todas' : 'All')),
            ...['physical', 'special', 'status'].map((c) => DropdownMenuItem(
                value: c,
                child: Row(children: [
                  MoveCategoryIcon(category: c),
                  const SizedBox(width: 6),
                  Flexible(child: Text(moveCategoryName(context, c)))
                ])))
          ],
          onChanged: (value) => _updateState(() {
                _category = value ?? '';
                _limit = 30;
              }));
      if (constraints.maxWidth < 300 ||
          MediaQuery.textScalerOf(context).scale(14) > 20) {
        return Column(
            children: [typeField, const SizedBox(height: 12), categoryField]);
      }
      return Row(children: [
        Expanded(child: typeField),
        const SizedBox(width: 12),
        Expanded(child: categoryField)
      ]);
    });
  }
}
