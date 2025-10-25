import 'package:flutter/material.dart';

/// Filter section widget for groups list
class GroupsFilterSection extends StatelessWidget {
  const GroupsFilterSection({
    super.key,
    required this.selectedType,
    required this.selectedStatus,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onClearFilters,
  });

  final String? selectedType;
  final String? selectedStatus;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bộ lọc',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Type filters
                _buildFilterChip(
                  label: 'PUBLIC',
                  icon: Icons.public,
                  isSelected: selectedType == 'PUBLIC',
                  onTap: () {
                    onTypeChanged(selectedType == 'PUBLIC' ? null : 'PUBLIC');
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'PRIVATE',
                  icon: Icons.lock_outline,
                  isSelected: selectedType == 'PRIVATE',
                  onTap: () {
                    onTypeChanged(selectedType == 'PRIVATE' ? null : 'PRIVATE');
                  },
                ),
                const SizedBox(width: 16),

                // Status filters
                _buildFilterChip(
                  label: 'ACTIVE',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  isSelected: selectedStatus == 'ACTIVE',
                  onTap: () {
                    onStatusChanged(
                      selectedStatus == 'ACTIVE' ? null : 'ACTIVE',
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'FORMING',
                  icon: Icons.hourglass_empty,
                  color: Colors.orange,
                  isSelected: selectedStatus == 'FORMING',
                  onTap: () {
                    onStatusChanged(
                      selectedStatus == 'FORMING' ? null : 'FORMING',
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'LOCKED',
                  icon: Icons.lock,
                  color: Colors.red,
                  isSelected: selectedStatus == 'LOCKED',
                  onTap: () {
                    onStatusChanged(
                      selectedStatus == 'LOCKED' ? null : 'LOCKED',
                    );
                  },
                ),

                // Clear filters button
                if (selectedType != null || selectedStatus != null) ...[
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: onClearFilters,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Xóa bộ lọc'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    Color color = Colors.blue,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
