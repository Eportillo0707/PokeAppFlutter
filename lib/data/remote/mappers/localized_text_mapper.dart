import 'package:pokeapp_flutter/data/remote/mappers/mapper_extensions.dart';
import 'package:pokeapp_flutter/ui/utils/pokemon_formatters.dart';

class LocalizedTextMapper {
  const LocalizedTextMapper();

  String flavorText(dynamic entries, String languageCode) {
    if (entries is! List) return '';
    final match = _localizedEntry(entries, languageCode);
    return cleanFlavorText(match?['flavor_text'] as String? ?? '');
  }

  String effectText(dynamic entries, String languageCode) {
    if (entries is! List) return '';
    final match = _localizedEntry(entries, languageCode);
    return cleanFlavorText(
      (match?['short_effect'] as String?) ??
          (match?['effect'] as String?) ??
          '',
    );
  }

  String name(
    dynamic names,
    String languageCode, {
    required String fallback,
  }) {
    if (names is! List) return formatPokemonName(fallback);
    final match = _localizedEntry(names, languageCode);
    return match?['name'] as String? ?? formatPokemonName(fallback);
  }

  Map<String, dynamic>? _localizedEntry(List entries, String languageCode) {
    final safeLanguage = languageCode == 'es' ? 'es' : 'en';
    final typedEntries = entries.cast<Map<String, dynamic>>();
    return typedEntries
            .where((entry) => entry['language']?['name'] == safeLanguage)
            .firstOrNull ??
        typedEntries
            .where((entry) => entry['language']?['name'] == 'en')
            .firstOrNull;
  }
}
