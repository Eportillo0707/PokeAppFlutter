import 'package:pokeapp_flutter/data/remote/mappers/localized_text_mapper.dart';
import 'package:pokeapp_flutter/data/remote/mappers/mapper_extensions.dart';
import 'package:pokeapp_flutter/domain/model/pokemon_models.dart';

class PokemonAbilityMapper {
  const PokemonAbilityMapper({
    LocalizedTextMapper textMapper = const LocalizedTextMapper(),
  }) : _textMapper = textMapper;

  final LocalizedTextMapper _textMapper;

  List<PokemonAbility> map(
    Map<String, dynamic> pokemon,
    List<Map<String, dynamic>> abilities,
    String languageCode,
  ) {
    return List<Map<String, dynamic>>.from(pokemon['abilities'] as List)
        .map((slot) {
      final name = slot['ability']['name'] as String;
      final ability =
          abilities.where((item) => item['name'] == name).firstOrNull;
      return PokemonAbility(
        name: _textMapper.name(
          ability?['names'],
          languageCode,
          fallback: name,
        ),
        flavorText: _abilityText(ability, languageCode),
      );
    }).toList();
  }

  String _abilityText(Map<String, dynamic>? ability, String languageCode) {
    if (ability == null) return '';
    final flavor = _textMapper.flavorText(
      ability['flavor_text_entries'],
      languageCode,
    );
    if (flavor.isNotEmpty) return flavor;
    return _textMapper.effectText(ability['effect_entries'], languageCode);
  }
}
