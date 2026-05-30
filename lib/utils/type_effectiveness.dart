class TypeEffectiveness {
  const TypeEffectiveness({
    this.veryWeakTo = const [],
    this.weakTo = const [],
    this.resistantTo = const [],
    this.veryResistantTo = const [],
    this.immuneTo = const [],
  });

  final List<String> veryWeakTo;
  final List<String> weakTo;
  final List<String> resistantTo;
  final List<String> veryResistantTo;
  final List<String> immuneTo;
}

const Map<String, Map<String, double>> defenseMultipliers = {
  'fire': {
    'water': 2,
    'rock': 2,
    'ground': 2,
    'fire': .5,
    'bug': .5,
    'grass': .5,
    'ice': .5,
    'steel': .5,
    'fairy': .5,
  },
  'water': {
    'electric': 2,
    'grass': 2,
    'fire': .5,
    'water': .5,
    'steel': .5,
    'ice': .5,
  },
  'grass': {
    'fire': 2,
    'ice': 2,
    'bug': 2,
    'flying': 2,
    'poison': 2,
    'grass': .5,
    'electric': .5,
    'ground': .5,
    'water': .5,
  },
  'normal': {'fighting': 2, 'ghost': 0},
  'fighting': {
    'flying': 2,
    'psychic': 2,
    'fairy': 2,
    'rock': .5,
    'bug': .5,
    'dark': .5,
  },
  'flying': {
    'electric': 2,
    'ice': 2,
    'rock': 2,
    'fighting': .5,
    'grass': .5,
    'bug': .5,
    'ground': 0,
  },
  'poison': {
    'ground': 2,
    'psychic': 2,
    'fairy': .5,
    'fighting': .5,
    'poison': .5,
    'grass': .5,
    'bug': .5,
  },
  'ground': {
    'water': 2,
    'grass': 2,
    'ice': 2,
    'poison': .5,
    'rock': .5,
    'electric': 0,
  },
  'rock': {
    'fighting': 2,
    'ground': 2,
    'steel': 2,
    'water': 2,
    'grass': 2,
    'normal': .5,
    'flying': .5,
    'poison': .5,
    'fire': .5,
  },
  'bug': {
    'flying': 2,
    'rock': 2,
    'fire': 2,
    'fighting': .5,
    'grass': .5,
    'ground': .5,
  },
  'ghost': {
    'ghost': 2,
    'dark': 2,
    'poison': .5,
    'bug': .5,
    'normal': 0,
    'fighting': 0,
  },
  'steel': {
    'fire': 2,
    'ground': 2,
    'fighting': 2,
    'normal': .5,
    'rock': .5,
    'flying': .5,
    'bug': .5,
    'grass': .5,
    'steel': .5,
    'psychic': .5,
    'ice': .5,
    'dragon': .5,
    'fairy': .5,
    'poison': 0,
  },
  'electric': {'ground': 2, 'flying': .5, 'steel': .5, 'electric': .5},
  'psychic': {
    'bug': 2,
    'ghost': 2,
    'dark': 2,
    'fighting': .5,
    'psychic': .5,
  },
  'ice': {'fighting': 2, 'rock': 2, 'steel': 2, 'fire': 2, 'ice': .5},
  'dragon': {
    'dragon': 2,
    'fairy': 2,
    'ice': 2,
    'fire': .5,
    'water': .5,
    'electric': .5,
    'grass': .5,
  },
  'dark': {
    'fighting': 2,
    'bug': 2,
    'fairy': 2,
    'ghost': .5,
    'dark': .5,
    'psychic': 0,
  },
  'fairy': {
    'poison': 2,
    'steel': 2,
    'fighting': .5,
    'bug': .5,
    'dark': .5,
    'dragon': 0,
  },
};

TypeEffectiveness getDefensiveEffectiveness(List<String> types) {
  final finalEffectiveness = <String, double>{};
  for (final type in types) {
    for (final entry in (defenseMultipliers[type] ?? {}).entries) {
      final current = finalEffectiveness[entry.key] ?? 1;
      finalEffectiveness[entry.key] = current * entry.value;
    }
  }

  final veryWeakTo = <String>[];
  final weakTo = <String>[];
  final resistantTo = <String>[];
  final veryResistantTo = <String>[];
  final immuneTo = <String>[];

  for (final entry in finalEffectiveness.entries) {
    final value = entry.value;
    if (value == 0) {
      immuneTo.add(entry.key);
    } else if (value == .5) {
      resistantTo.add(entry.key);
    } else if (value > .1 && value < .5) {
      veryResistantTo.add(entry.key);
    } else if (value > 1.1 && value <= 2) {
      weakTo.add(entry.key);
    } else if (value > 2.1) {
      veryWeakTo.add(entry.key);
    }
  }

  return TypeEffectiveness(
    veryWeakTo: veryWeakTo,
    weakTo: weakTo,
    resistantTo: resistantTo,
    veryResistantTo: veryResistantTo,
    immuneTo: immuneTo,
  );
}
