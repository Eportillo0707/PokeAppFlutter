import 'dart:io';
import 'catalog_active_store.dart';
import 'catalog_decompress.dart';
import 'catalog_file_verifier.dart';
import 'catalog_manifest.dart';
import 'catalog_sqlite_validator.dart';
import 'catalog_version.dart';

class CatalogInstaller {
  CatalogInstaller(this.store, {CatalogFileVerifier? verifier,
    CatalogSqliteValidator? sqliteValidator})
      : verifier = verifier ?? CatalogFileVerifier(),
        sqliteValidator = sqliteValidator ?? CatalogSqliteValidator();

  final CatalogActiveStore store;
  final CatalogFileVerifier verifier;
  final CatalogSqliteValidator sqliteValidator;

  Future<void> install(CatalogManifest manifest, Directory staging) async {
    final current = await store.activeVersion();
    if (manifest.baseVersion != current ||
        compareCatalogVersions(manifest.version, current) <= 0) {
      throw const FormatException('Catalog base version changed');
    }
    if (manifest.files.length != 1 ||
        manifest.files.single.path != 'catalog.sqlite.gz') {
      throw const FormatException('Media updates are not supported yet');
    }
    final entry = manifest.files.single;
    final compressed = File('${staging.path}/${entry.asset}');
    if (!await verifier.matches(compressed, entry)) {
      throw const FormatException('Catalog download is incomplete');
    }
    final directory = store.versionDirectory(manifest.version);
    if (await directory.exists()) {
      throw StateError('Catalog version already prepared');
    }
    await directory.create(recursive: true);
    try {
      final file = File('${directory.path}/catalog.sqlite');
      await decompressCatalog(compressed, file);
      await sqliteValidator.validate(file, store.seed);
      await store.activate(manifest.version);
    } catch (_) {
      await directory.delete(recursive: true);
      rethrow;
    }
  }
}
