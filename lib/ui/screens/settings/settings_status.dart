import 'package:pokeapp_flutter/data/updates/catalog_update_service.dart';

String catalogUpdateStatus(bool spanish, CatalogUpdateService? updates) {
  if (updates == null) {
    return spanish
      ? 'La comprobación no está configurada en esta compilación.'
      : 'Update checks are not configured in this build.';
  }
  if (updates.checking) {
    return spanish ? 'Buscando...' : 'Checking...';
  }
  if (updates.error != null) {
    return spanish
      ? 'No se pudo comprobar. Inténtalo de nuevo.'
      : 'Could not check. Please try again.';
  }
  if (updates.available != null) {
    return spanish
      ? 'Versión ${updates.available!.version} disponible'
      : 'Version ${updates.available!.version} available';
  }
  return spanish ? 'Catálogo actualizado' : 'Catalog up to date';
}
