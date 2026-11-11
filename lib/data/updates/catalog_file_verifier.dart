import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'catalog_manifest.dart';

class CatalogFileVerifier {
  Future<bool> matches(File file, CatalogFile entry) async {
    if (!await file.exists() || await file.length() != entry.bytes) {
      return false;
    }
    final digest = await Sha256().hash(await file.readAsBytes());
    final actual = digest.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return actual == entry.sha256;
  }
}
