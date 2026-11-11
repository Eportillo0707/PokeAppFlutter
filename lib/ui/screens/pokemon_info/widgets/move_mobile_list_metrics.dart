part of 'move_mobile_list.dart';

extension _MoveMobileListMetrics on _MoveMobileListState {
  Widget _metric(String label, String value) => SizedBox(
      width: 48,
      child: Column(children: [
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10)),
        const SizedBox(height: 3),
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))
      ]));
}
