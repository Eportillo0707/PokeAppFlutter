import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/data/local/teams_store.dart';
import 'package:pokeapp_flutter/data/local/favorites_store.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';
import 'package:pokeapp_flutter/domain/repositories/pokemon_repository.dart';
import 'team_defense_panel.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';
import 'package:pokeapp_flutter/ui/screens/pokemon_info/pokemon_detail_screen.dart';
import 'team_pokemon_picker.dart';
part 'teams_screen_presentation.dart';
part 'teams_name_dialog_presentation.dart';
part 'teams_overview_presentation.dart';
part 'teams_empty_presentation.dart';
part 'teams_screen_editor.dart';

Future<String?> teamNameDialog(BuildContext context, {String initial = ''}) =>
    showDialog<String>(
        context: context, builder: (_) => _TeamNameDialog(initial: initial));

class _TeamNameDialog extends StatefulWidget {
  const _TeamNameDialog({required this.initial});
  final String initial;
  @override
  State<_TeamNameDialog> createState() => _TeamNameDialogState();
}

class _TeamNameDialogState extends State<_TeamNameDialog> {
  late final controller = TextEditingController(text: widget.initial);
  final form = GlobalKey<FormState>();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void submit() {
    if (form.currentState!.validate()) {
      Navigator.pop(context, controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) => _buildNameDialog(context);
}

class TeamsScreen extends StatefulWidget {
  const TeamsScreen(
      {super.key,
      required this.store,
      required this.api,
      required this.favorites});
  final TeamsStore store;
  final PokemonRepository api;
  final FavoritesStore favorites;
  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  void _reload() => setState(() => loading = widget.store.load());
  late Future<void> loading;
  @override
  void initState() {
    super.initState();
    loading = widget.store.load();
  }

  void open(String id) => Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => TeamEditorScreen(
            id: id,
            store: widget.store,
            api: widget.api,
            favorites: widget.favorites,
          )));
  Future<void> create() async {
    final name = await teamNameDialog(context);
    if (name == null || !mounted) return;
    try {
      final id = await widget.store.create(name);
      if (mounted) open(id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.loadError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) => _buildOverview(context);
}
