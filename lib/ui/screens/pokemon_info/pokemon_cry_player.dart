import 'package:audioplayers/audioplayers.dart';
import 'package:pokeapp_flutter/data/updates/catalog_media_resolver.dart';

Future<void> playPokemonCry(AudioPlayer player, String url) async {
  await player.stop();
  if (url.startsWith('http')) {
    await player.play(UrlSource(url));
    return;
  }
  final key = 'assets/$url';
  final media = CatalogMediaResolver.current;
  final file = media.fileFor(key);
  await player.play(file == null
      ? AssetSource(media.assetFor(key).substring('assets/'.length))
      : DeviceFileSource(file.path));
}
