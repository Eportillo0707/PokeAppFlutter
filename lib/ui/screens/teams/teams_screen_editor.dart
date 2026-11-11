part of 'teams_screen.dart';

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
