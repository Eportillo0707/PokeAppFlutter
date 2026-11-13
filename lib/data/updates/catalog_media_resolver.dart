import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'catalog_file_verifier.dart';
import 'catalog_cry_formats.dart';
import 'catalog_manifest.dart';
import 'catalog_media_index.dart';

class CatalogMediaResolver extends CachingAssetBundle {
  CatalogMediaResolver._(this.files, this.aliases, this.cryMp3Ids);

  static CatalogMediaResolver current = CatalogMediaResolver._({}, {}, {});
  final Map<String, File> files;
  final Map<String, String> aliases;
  final Set<int> cryMp3Ids;

  static Future<CatalogMediaResolver> open(
      Database database, File selected, File seed) async {
    final base = selected.path == seed.path
        ? database
        : await openDatabase(seed.path, readOnly: true, singleInstance: false);
    late CatalogMediaIndex active;
    late CatalogMediaIndex bundled;
    try {
      final formats = await bundledCryFormats(base);
      active = await CatalogMediaIndex.read(database, cryFormats: formats);
      bundled = await CatalogMediaIndex.read(base, cryFormats: formats);
    } finally {
      if (base != database) await base.close();
    }
    final mp3 = <int>{};
    for (final path in active.assets.keys) {
      final match = RegExp(r'/cries/(\d+)\.mp3$').firstMatch(path);
      if (match != null) mp3.add(int.parse(match.group(1)!));
    }
    if (selected.path == seed.path) {
      return CatalogMediaResolver._({}, {}, mp3);
    }
    final files = <String, File>{};
    final aliases = <String, String>{};
    final bundledById = <String, String>{
      for (final entry in bundled.assets.entries) entry.value.id: entry.key,
    };
    final verifier = CatalogFileVerifier();
    for (final entry in active.assets.entries) {
      final media = entry.value;
      if (bundled.assets[entry.key]?.id == media.id) continue;
      final bundledPath = bundledById[media.id];
      if (bundledPath != null) {
        aliases[entry.key] = bundledPath;
        continue;
      }
      final file = File('${selected.parent.path}/${media.path}');
      final asset = 'media-${media.path.substring(6)}';
      final expected = CatalogFile(media.path, asset, media.bytes, media.id);
      if (!await verifier.matches(file, expected)) {
        throw const FormatException('Active catalog media is missing');
      }
      files[entry.key] = file;
    }
    return CatalogMediaResolver._(files, aliases, mp3);
  }

  File? fileFor(String path) => files[path];
  String assetFor(String path) => aliases[path] ?? path;

  @override
  Future<ByteData> load(String key) async {
    final file = files[key];
    if (file == null) return rootBundle.load(assetFor(key));
    return ByteData.sublistView(await file.readAsBytes());
  }
}
