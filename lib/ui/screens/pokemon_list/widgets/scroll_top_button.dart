import 'package:flutter/material.dart';

class ScrollTopButton extends StatelessWidget {
  const ScrollTopButton({super.key, required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF232B4C),
      onPressed: () => controller.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      ),
      child: const Icon(Icons.arrow_upward, color: Colors.white),
    );
  }
}
