part of 'app_bottom_nav.dart';

class _BottomTab extends StatelessWidget {
  const _BottomTab({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final Widget icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Material(
          color: selected
              ? Colors.white.withValues(alpha: .14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: Semantics(
            label: title,
            button: true,
            selected: selected,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconTheme(
                    data: IconThemeData(
                      color: selected ? Colors.white : Colors.white70,
                      size: 27,
                    ),
                    child: ExcludeSemantics(child: icon),
                  ),
                  const SizedBox(height: 6),
                  _SelectionIndicator(selected: selected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35,
      height: 3,
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }
}
