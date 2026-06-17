import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/ui/components/pokemon_widgets.dart';
import 'package:pokeapp_flutter/ui/l10n/app_localizations.dart';

class SearchPokemonBar extends StatelessWidget {
  const SearchPokemonBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onTypeSelected,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        cursorColor: Colors.white,
        textInputAction: TextInputAction.search,
        decoration: _inputDecoration(context),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF232B4C),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      enabledBorder: _border,
      focusedBorder: _border,
      hintText: context.l10n.search,
      hintStyle: const TextStyle(color: Colors.white),
      prefixIcon: const Icon(Icons.search, color: Colors.white, size: 18),
      suffixIcon: IconButton(
        onPressed: () => _showTypePicker(context),
        icon: const Icon(Icons.tune, color: Colors.white, size: 18),
      ),
    );
  }

  OutlineInputBorder get _border => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: .5),
      );

  void _showTypePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF232B4C),
      builder: (_) => TypePickerSheet(
        useImages: true,
        onSelected: (type) {
          Navigator.pop(context);
          onTypeSelected(type);
        },
      ),
    );
  }
}
