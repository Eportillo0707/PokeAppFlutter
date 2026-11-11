class CatalogFile {
  const CatalogFile(this.path, this.asset, this.bytes, this.sha256);

  final String path;
  final String asset;
  final int bytes;
  final String sha256;

  factory CatalogFile.fromJson(Map<String, dynamic> json) {
    final path = json['path'];
    final asset = json['asset'];
    final bytes = json['bytes'];
    final sha256 = json['sha256'];
    if (path is! String || asset is! String || bytes is! int || bytes < 0 ||
        sha256 is! String || !RegExp(r'^[a-f0-9]{64}$').hasMatch(sha256) ||
        (path != 'catalog.sqlite.gz' &&
            !RegExp(r'^media/[a-f0-9]{64}\.(webp|ogg|mp3)$').hasMatch(path)) ||
        asset != (path == 'catalog.sqlite.gz'
            ? path : 'media-${path.substring(6)}')) {
      throw const FormatException('Invalid catalog file');
    }
    return CatalogFile(path, asset, bytes, sha256);
  }
}

class CatalogManifest {
  const CatalogManifest(this.version, this.baseVersion, this.files);

  final String version;
  final String baseVersion;
  final List<CatalogFile> files;
  int get downloadBytes => files.fold(0, (sum, file) => sum + file.bytes);

  factory CatalogManifest.fromJson(Map<String, dynamic> json) {
    if (json['formatVersion'] != 1 || json['schemaVersion'] != 1 ||
        json['channel'] != 'offlinetest' || json['minAppVersion'] != '1.1.0') {
      throw const FormatException('Incompatible catalog manifest');
    }
    final version = json['catalogVersion'];
    final base = json['baseCatalogVersion'];
    final pattern = RegExp(r'^\d{4}\.\d{2}\.\d{2}(?:\.\d+)?$');
    if (version is! String || base is! String ||
        !pattern.hasMatch(version) || !pattern.hasMatch(base)) {
      throw const FormatException('Invalid catalog version');
    }
    final raw = json['files'];
    if (raw is! List) throw const FormatException('Missing catalog files');
    final files = raw.map((item) =>
        CatalogFile.fromJson(Map<String, dynamic>.from(item as Map))).toList();
    if (files.where((file) => file.path == 'catalog.sqlite.gz').length != 1 ||
        files.map((file) => file.path).toSet().length != files.length) {
      throw const FormatException('Invalid catalog file list');
    }
    return CatalogManifest(version, base, files);
  }
}
