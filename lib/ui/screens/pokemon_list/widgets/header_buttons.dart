import 'package:flutter/material.dart';

class HeaderButtons extends StatelessWidget {
  const HeaderButtons({
    super.key,
    required this.onSearch,
    required this.onFilter,
  });

  final VoidCallback onSearch;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 350,
        height: 38,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onSearch,
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFF232B4C),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.grey, width: .5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 44,
              child: OutlinedButton(
                onPressed: onFilter,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: const Color(0xFF232B4C),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.grey, width: .5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.tune, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
