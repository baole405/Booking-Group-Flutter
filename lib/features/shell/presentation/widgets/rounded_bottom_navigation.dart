import 'package:booking_group_flutter/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class RoundedBottomNavigation extends StatelessWidget {
  const RoundedBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final List<IconData> items;

  @override
  Widget build(BuildContext context) {
    assert(items.length >= 2, 'Need at least two navigation items');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          items.length,
          (index) {
            final isSelected = index == currentIndex;
            return GestureDetector(
              onTap: () => onItemSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color.fromRGBO(255, 255, 255, 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  items[index],
                  color: isSelected
                      ? Colors.white
                      : const Color.fromRGBO(255, 255, 255, 0.7),
                  size: 24,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
