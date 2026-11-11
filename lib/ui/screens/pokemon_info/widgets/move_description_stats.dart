part of 'move_description_sheet.dart';

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
