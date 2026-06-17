// ignore_for_file: invalid_use_of_protected_member

part of 'pokemon_detail_screen.dart';

extension _PokemonDetailScreenActions on _PokemonDetailScreenState {
  void _retry() => setState(
        () => controller.retry(context.l10n.languageCode),
      );

  void _selectPage(int page) => setState(() => controller.selectedPage = page);

  void _toggleShiny() {
    setState(() => controller.showShiny = !controller.showShiny);
  }

  Future<void> _toggle(PokemonInfo pokemon) async {
    await controller.toggleFavorite(pokemon);
    setState(() {});
  }

  Future<void> _popWithHero() async {
    if (controller.isPopping) return;
    controller.isPopping = true;
    await controller.prepareHeroPop(() => setState(() {}));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _openEvolution(
    PokemonSpecies species,
    PokemonDetailRoutes routes,
  ) async {
    final pokemon = await controller.getPokemonItem(species);
    await routes.openEvolution(pokemon);
  }

  Future<void> _playCry(PokemonInfo pokemon, PokemonDetailRoutes routes) async {
    try {
      await controller.playCry(pokemon);
    } catch (_) {
      routes.showCryError();
    }
  }
}
