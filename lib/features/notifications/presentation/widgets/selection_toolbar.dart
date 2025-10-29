import 'package:flutter/material.dart';

class SelectionToolbar extends StatelessWidget {
  const SelectionToolbar({
    super.key,
    required this.allSelected,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onDelete,
  });

  final bool allSelected;
  final int selectedCount;
  final ValueChanged<bool?> onSelectAll;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Checkbox(
            value: allSelected,
            onChanged: onSelectAll,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              selectedCount > 0
                  ? '$selectedCount notifications selected'
                  : 'Select notifications',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
