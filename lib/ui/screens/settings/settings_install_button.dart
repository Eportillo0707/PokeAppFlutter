import 'package:flutter/material.dart';
import 'package:pokeapp_flutter/data/updates/catalog_update_service.dart';

class SettingsInstallButton extends StatelessWidget {
  const SettingsInstallButton(
      {super.key, required this.updates, required this.spanish});

  final CatalogUpdateService? updates;
  final bool spanish;

  @override
  Widget build(BuildContext context) {
    final manifest = updates?.available;
    if (manifest == null) {
      return const SizedBox.shrink();
    }
    final total = manifest.downloadBytes;
    final progress = updates!.installing && total > 0
        ? updates!.downloadedBytes / total
        : null;
    return Column(children: [
      const SizedBox(height: 12),
      if (updates!.installing) LinearProgressIndicator(value: progress),
      const SizedBox(height: 8),
      FilledButton(
        onPressed: updates!.installing ? null : () => _confirm(context, total),
        child: Text(spanish ? 'Actualizar ahora' : 'Update now'),
      ),
    ]);
  }

  Future<void> _confirm(BuildContext context, int bytes) async {
    final size = (bytes / 1048576).toStringAsFixed(1);
    final accepted = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
              title: Text(spanish ? 'Actualizar catálogo' : 'Update catalog'),
              content: Text(spanish
                  ? 'Se descargarán $size MiB. Podrás seguir usando la app.'
                  : '$size MiB will be downloaded. You can keep using the app.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialog, false),
                    child: Text(spanish ? 'Más tarde' : 'Later')),
                TextButton(
                    onPressed: () => Navigator.pop(dialog, true),
                    child: Text(spanish ? 'Descargar' : 'Download')),
              ],
            ));
    if (accepted == true) await updates?.installAvailable();
  }
}
