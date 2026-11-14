import 'dart:io';
import 'catalog_active_store.dart';
import 'catalog_decompress.dart';
import 'catalog_file_verifier.dart';
import 'catalog_manifest.dart';
import 'catalog_media_installer.dart';
import 'catalog_sqlite_validator.dart';
import 'catalog_version.dart';

class CatalogInstaller {
  CatalogInstaller(this.store,
      {CatalogFileVerifier? verifier, CatalogSqliteValidator? sqliteValidator})
      : verifier = verifier ?? CatalogFileVerifier(),
        sqliteValidator = sqliteValidator ?? CatalogSqliteValidator();

  final CatalogActiveStore store;
  final CatalogFileVerifier verifier;
  final CatalogSqliteValidator sqliteValidator;

  Future<void> install(CatalogManifest manifest, Directory staging) async {
    final current = await store.activeVersion();
    if (compareCatalogVersions(manifest.baseVersion, current) > 0 ||
        compareCatalogVersions(manifest.version, current) <= 0) {
      throw const FormatException('Catalog base version changed');
    }
    final entry =
        manifest.files.firstWhere((file) => file.path == 'catalog.sqlite.gz');
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
      await sqliteValidator.validate(file);
      await CatalogMediaInstaller(verifier).install(
          catalog: file,
          seed: store.seed,
          previous: store.versionDirectory(current),
          staging: staging,
          target: directory,
          manifest: manifest);
      await store.activate(manifest.version);
    } catch (_) {
      await directory.delete(recursive: true);
      rethrow;
    }
  }
}
