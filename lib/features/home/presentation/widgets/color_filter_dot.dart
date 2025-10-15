import 'package:booking_group_flutter/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ColorFilterDot extends StatelessWidget {
  const ColorFilterDot({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppTheme.primaryDark : Colors.transparent,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}
