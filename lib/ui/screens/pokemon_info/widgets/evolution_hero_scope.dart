import 'package:flutter/material.dart';

class EvolutionHeroScope extends InheritedWidget {
  const EvolutionHeroScope(
      {super.key, required this.selected, required super.child});
  final String? selected;
  static bool enabled(BuildContext context, String name) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<EvolutionHeroScope>();
    return scope == null || scope.selected == name;
  }

  @override
  bool updateShouldNotify(EvolutionHeroScope oldWidget) =>
      selected != oldWidget.selected;
}
