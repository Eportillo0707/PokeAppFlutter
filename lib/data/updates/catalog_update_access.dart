import 'package:flutter/foundation.dart';

const bool catalogUpdateAccess = !kReleaseMode ||
    bool.fromEnvironment('POKEAPP_INTERNAL_CATALOG_TEST');
