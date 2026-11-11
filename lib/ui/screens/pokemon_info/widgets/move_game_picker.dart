import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/l10n/move_localizations.dart';
part 'move_game_picker_presentation.dart';
part 'move_game_picker_groups.dart';

Future<String?> showMoveGamePicker(
    BuildContext context, List<String> games, String selected) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) => _GamePicker(games: games, selected: selected),
  );
}

class _GamePicker extends StatefulWidget {
  const _GamePicker({required this.games, required this.selected});
  final List<String> games;
  final String selected;
  @override
  State<_GamePicker> createState() => _GamePickerState();
}

class _GamePickerState extends State<_GamePicker> {
  void _updateState(VoidCallback change) => setState(change);
  String query = '';
  static const generations = [
    ['red-blue', 'yellow', 'red-green', 'blue'],
    ['gold-silver', 'crystal'],
    ['ruby-sapphire', 'emerald', 'firered-leafgreen', 'colosseum', 'xd'],
    ['diamond-pearl', 'platinum', 'heartgold-soulsilver'],
    ['black-white', 'black-2-white-2'],
    ['x-y', 'omega-ruby-alpha-sapphire'],
    ['sun-moon', 'ultra-sun-ultra-moon', 'lets-go-pikachu-lets-go-eevee'],
    ['sword-shield', 'brilliant-diamond-shining-pearl', 'legends-arceus'],
    ['scarlet-violet', 'legends-z-a'],
  ];

  @override
  Widget build(BuildContext context) => _buildPicker(context);
}
