import 'dart:convert';
import 'dart:io';

class CatalogActiveStore {
  CatalogActiveStore(this.databaseDirectory);

  final Directory databaseDirectory;
  Directory get root => Directory('${databaseDirectory.path}/catalog-updates');
  File get pointer => File('${root.path}/active.json');
  File get seed => File('${databaseDirectory.path}/catalog-v1.sqlite');

  Directory versionDirectory(String version) {
    if (!RegExp(r'^\d{4}\.\d{2}\.\d{2}(?:\.\d+)?$').hasMatch(version)) {
      throw const FormatException('Invalid catalog version');
    }
    return Directory('${root.path}/versions/$version');
  }

  Future<Map<String, String?>> _readPointer() async {
    try {
      final value = jsonDecode(await pointer.readAsString()) as Map;
      return {'active': value['active'] as String?,
        'previous': value['previous'] as String?};
    } catch (_) {
      return {'active': null, 'previous': null};
    }
  }

  Future<String> activeVersion() async =>
      (await _readPointer())['active'] ?? '2026.11.05';

  Future<List<File>> candidates() async {
    final state = await _readPointer();
    final files = <File>[];
    for (final version in [state['active'], state['previous']]) {
      if (version == null) continue;
      try {
        files.add(File('${versionDirectory(version).path}/catalog.sqlite'));
      } on FormatException { /* Ignore a damaged pointer. */ }
    }
    return [...files, seed];
  }

  Future<void> activate(String version) async {
    final current = (await _readPointer())['active'];
    final file = File('${versionDirectory(version).path}/catalog.sqlite');
    if (!await file.exists()) throw StateError('Prepared catalog missing');
    await root.create(recursive: true);
    final temporary = File('${pointer.path}.tmp');
    await temporary.writeAsString(jsonEncode({
      'active': version, 'previous': current,
    }), flush: true);
    await temporary.rename(pointer.path);
  }

  Future<void> recover(File working) async {
    if (working.path == seed.path) {
      if (await pointer.exists()) await pointer.delete();
      return;
    }
    final version = working.parent.path.replaceAll('\\', '/').split('/').last;
    if (working.path != '${versionDirectory(version).path}/catalog.sqlite') {
      throw const FormatException('Invalid recovery target');
    }
    final temporary = File('${pointer.path}.tmp');
    await temporary.writeAsString(jsonEncode({
      'active': version, 'previous': null,
    }), flush: true);
    await temporary.rename(pointer.path);
  }
}
