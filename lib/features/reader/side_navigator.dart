import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SideNavigator extends StatelessWidget {
  const SideNavigator({
    super.key,
    required this.hasPrev,
    required this.hasNext,
    required this.onFirst,
    required this.onPrev,
    required this.onNext,
    required this.onLast,
  });

  final bool hasPrev;
  final bool hasNext;
  final VoidCallback onFirst;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _navButton(
          icon: Icons.keyboard_double_arrow_up_rounded,
          enabled: hasPrev,
          onTap: onFirst,
        ),
        const SizedBox(height: 8),
        _navButton(
          icon: Icons.keyboard_arrow_up_rounded,
          enabled: hasPrev,
          onTap: onPrev,
        ),
        const SizedBox(height: 16),
        _navButton(
          icon: Icons.keyboard_arrow_down_rounded,
          enabled: hasNext,
          onTap: onNext,
        ),
        const SizedBox(height: 8),
        _navButton(
          icon: Icons.keyboard_double_arrow_down_rounded,
          enabled: hasNext,
          onTap: onLast,
        ),
      ],
    );
  }

  Widget _navButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}

