import 'package:sqflite/sqflite.dart';

class CatalogMediaRecord {
  const CatalogMediaRecord(this.id, this.path, this.bytes);
  final String id;
  final String path;
  final int bytes;
}

class CatalogMediaIndex {
  const CatalogMediaIndex(this.assets);
  final Map<String, CatalogMediaRecord> assets;

  static Future<CatalogMediaIndex> read(Database database,
      {Map<String, String> cryFormats = const {}}) async {
    final rows = await database
        .rawQuery('SELECT asset_id, relative_path, sha256, bytes FROM media');
    final media = <String, CatalogMediaRecord>{};
    for (final row in rows) {
      final id = row['asset_id'];
      final path = row['relative_path'];
      final bytes = row['bytes'];
      if (id is! String ||
          path is! String ||
          bytes is! int ||
          bytes < 1 ||
          row['sha256'] != id ||
          !RegExp(r'^[a-f0-9]{64}$').hasMatch(id) ||
          !RegExp(r'^media/[a-f0-9]{64}\.(webp|ogg|mp3)$').hasMatch(path) ||
          !path.startsWith('media/$id.')) {
        throw const FormatException('Invalid catalog media');
      }
      media[id] = CatalogMediaRecord(id, path, bytes);
    }
    final assets = <String, CatalogMediaRecord>{};
    void add(String path, Object? id) {
      if (id == null) return;
      final record = media[id];
      if (record == null) throw const FormatException('Missing media row');
      if (path.endsWith('.webp') && !record.path.endsWith('.webp')) {
        throw const FormatException('Invalid image media');
      }
      assets[path] = record;
    }

    final pokemon = await database.rawQuery(
        'SELECT id, normal_asset, shiny_asset, cry_asset FROM pokemon');
    for (final row in pokemon) {
      final id = row['id'];
      final normal = row['normal_asset'];
      add('assets/offline_catalog/normal/$id.webp', normal);
      add('assets/offline_catalog/shiny/$id.webp',
          row['shiny_asset'] ?? normal);
      final cry = media[row['cry_asset']];
      if (row['cry_asset'] != null && cry == null) {
        throw const FormatException('Missing cry media');
      }
      if (cry != null) {
        final extension = cryFormats[cry.id] ?? cry.path.split('.').last;
        add('assets/offline_catalog/cries/$id.$extension', row['cry_asset']);
      }
    }
    final items = await database
        .rawQuery('SELECT item_name, asset_id FROM evolution_items');
    for (final row in items) {
      add('assets/offline_catalog/items/${row['item_name']}.webp',
          row['asset_id']);
    }
    return CatalogMediaIndex(assets);
  }
}
