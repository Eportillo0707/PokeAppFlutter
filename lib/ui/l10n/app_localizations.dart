import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('es'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  bool get isSpanish => locale.languageCode == 'es';
  String get languageCode => isSpanish ? 'es' : 'en';

  String get pokemon => 'Pokemon';
  String get favorites => isSpanish ? 'Favoritos' : 'Favorites';
  String get search => isSpanish ? 'Buscar' : 'Search';
  String get noFavorites =>
      isSpanish ? 'Aun no hay favoritos' : 'No favorites yet';
  String get noResults => isSpanish ? 'Sin resultados' : 'No results';
  String get selectType => isSpanish ? 'Selecciona un tipo' : 'Select a Type';
  String get loadError => isSpanish
      ? 'No se pudo cargar la informacion.'
      : 'Information could not be loaded.';
  String get retry => isSpanish ? 'Reintentar' : 'Retry';

  String get description => isSpanish ? 'Descripcion' : 'Description';
  String get descriptionUnavailable =>
      isSpanish ? 'Descripcion no disponible.' : 'Description unavailable.';
  String get height => isSpanish ? 'Altura' : 'Height';
  String get weight => isSpanish ? 'Peso' : 'Weight';
  String get abilities => isSpanish ? 'Habilidades' : 'Abilities';
  String get evolutionChain =>
      isSpanish ? 'Cadena evolutiva' : 'Evolution Chain';
  String get megaEvolutions =>
      isSpanish ? 'Megaevoluciones' : 'Mega Evolutions';
  String get resistances => isSpanish ? 'Resistencias' : 'Resistances';
  String get weaknesses => isSpanish ? 'Debilidades' : 'Weaknesses';
  String get immunities => isSpanish ? 'Inmunidades:' : 'Immunities:';

  String multiplierFrom(String multiplier) {
    return isSpanish ? 'De $multiplier:' : '$multiplier From:';
  }

  String statName(String value) {
    final normalized = value.toLowerCase();
    if (!isSpanish) return normalized.toUpperCase();
    return switch (normalized) {
      'hp' => 'PS',
      'attack' => 'ATAQUE',
      'defense' => 'DEFENSA',
      'special-attack' => 'ATAQUE ESPECIAL',
      'special-defense' => 'DEFENSA ESPECIAL',
      'speed' => 'VELOCIDAD',
      _ => normalized.toUpperCase(),
    };
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .map((supported) => supported.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final languageCode = locale.languageCode == 'es' ? 'es' : 'en';
    return AppLocalizations(Locale(languageCode));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
