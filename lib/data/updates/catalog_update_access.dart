import 'package:flutter/foundation.dart';

const bool catalogUpdateAccess = !kReleaseMode ||
    bool.fromEnvironment('POKEAPP_INTERNAL_CATALOG_TEST') ||
    bool.fromEnvironment('POKEAPP_ENABLE_CATALOG_UPDATES');
