import 'package:flutter/material.dart';

import 'package:pokeapp_flutter/ui/components/pokemon_widgets.dart';

class TypeScreenHeader extends StatelessWidget {
  const TypeScreenHeader({super.key, required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Align(child: TypeBadgeImage(type: type, width: 120)),
        ],
      ),
    );
  }
}
