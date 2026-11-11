import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokeapp_flutter/data/updates/catalog_update_checker.dart';
import 'package:pokeapp_flutter/data/updates/catalog_update_service.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';
import 'settings_status.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.updates});
  final CatalogUpdateService? updates;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ValueNotifier<int> _idle = ValueNotifier(0);
  String? lastChecked;

  @override
  void dispose() {
    widget.updates?.removeListener(_onUpdate);
    _idle.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.updates?.addListener(_onUpdate);
    _loadLastCheck();
  }

  void _onUpdate() {
    if (widget.updates?.checking == false) {
      _loadLastCheck();
    }
  }

  Future<void> _loadLastCheck() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => lastChecked =
        prefs.getString(CatalogUpdateChecker.lastSuccessKey));
    }
  }

  Future<void> _check() async {
    await widget.updates?.check(manual: true);
    await _loadLastCheck();
  }

  @override
  Widget build(BuildContext context) {
    final spanish = context.l10n.isSpanish;
    final updates = widget.updates;
    return Scaffold(
      appBar: AppBar(title: Text(spanish ? 'Ajustes' : 'Settings')),
      body: ListenableBuilder(
        listenable: updates ?? _idle,
        builder: (context, _) => ListView(padding: const EdgeInsets.all(20),
          children: [
            Text(spanish ? 'Actualizaciones del catálogo' : 'Catalog updates',
              style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('${spanish ? 'Versión instalada' : 'Installed version'}: '
              '2026.11.05'),
            const SizedBox(height: 8),
            Text(lastChecked == null
              ? (spanish ? 'Nunca se ha comprobado' : 'Never checked')
              : '${spanish ? 'Última comprobación' : 'Last checked'}: '
                '${lastChecked!.substring(0, 10)}'),
            const SizedBox(height: 16),
            Text(catalogUpdateStatus(spanish, updates)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: updates == null || updates.checking ? null : _check,
              icon: const Icon(Icons.refresh),
              label: Text(spanish ? 'Buscar actualizaciones' : 'Check for updates'),
            ),
          ]),
      ),
    );
  }

}
