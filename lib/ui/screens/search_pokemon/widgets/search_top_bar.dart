import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/ui/screens/search_pokemon/widgets/search_back_button.dart';
import 'package:pokeapp_flutter/ui/screens/search_pokemon/widgets/search_pokemon_bar.dart';

class SearchTopBar extends StatelessWidget {
  const SearchTopBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onBack,
    required this.onTypeSelected,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onBack;
  final ValueChanged<String> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          SearchBackButton(onPressed: onBack),
          const SizedBox(width: 8),
          Expanded(
            child: SearchPokemonBar(
              controller: controller,
              focusNode: focusNode,
              onTypeSelected: onTypeSelected,
            ),
          ),
        ],
      ),
    );
  }
}
