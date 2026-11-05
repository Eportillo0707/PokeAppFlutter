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

class TeamEditorScreen extends StatefulWidget {
  const TeamEditorScreen(
      {super.key,
      required this.id,
      required this.store,
      required this.api,
      required this.favorites});
  final String id;
  final TeamsStore store;
  final PokemonRepository api;
  final FavoritesStore favorites;
  @override
  State<TeamEditorScreen> createState() => _TeamEditorScreenState();
}

class _TeamEditorScreenState extends State<TeamEditorScreen> {
  bool busy = false;
  Future<void> save(Future<void> Function() action) async {
    setState(() => busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.l10n.isSpanish
                ? 'No se pudo guardar el equipo. Inténtalo de nuevo.'
                : 'Could not save the team. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> add() async {
    final team = widget.store.find(widget.id)!;
    final pokemon = await Navigator.of(context).push<PokemonItem>(
        MaterialPageRoute(
            builder: (_) => TeamPokemonPicker(
                api: widget.api,
                excluded: team.members.map((p) => p.id).toSet())));
    if (pokemon != null && mounted) {
      await save(() => widget.store.add(widget.id, pokemon));
    }
  }

  Future<void> rename() async {
    final name = await teamNameDialog(context,
        initial: widget.store.find(widget.id)!.name);
    if (name != null && mounted) {
      await save(() => widget.store.rename(widget.id, name));
    }
  }

  Future<void> delete() async {
    final es = context.l10n.isSpanish;
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(es ? '¿Eliminar este equipo?' : 'Delete this team?'),
              content: Text(widget.store.find(widget.id)!.name),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(es ? 'Cancelar' : 'Cancel')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(es ? 'Eliminar' : 'Delete'))
              ],
            ));
    if (confirmed == true && mounted) {
      await save(() => widget.store.delete(widget.id));
      if (mounted && widget.store.find(widget.id) == null) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) => _buildEditor(context);
}
