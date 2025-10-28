import 'package:booking_group_flutter/models/my_group.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GroupInfoCard extends StatelessWidget {
  final MyGroup group;
  final int memberCount;
  final bool showLeaderActions;
  final bool actionsEnabled;
  final VoidCallback? onEditInfo;
  final VoidCallback? onToggleType;
  final VoidCallback? onCompleteGroup;

  const GroupInfoCard({
    super.key,
    required this.group,
    required this.memberCount,
    this.showLeaderActions = false,
    this.actionsEnabled = true,
    this.onEditInfo,
    this.onToggleType,
    this.onCompleteGroup,
  });

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'INACTIVE':
        return Colors.grey;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'PRIVATE':
        return Colors.purple;
      case 'PUBLIC':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(group.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(group.status)),
                  ),
                  child: Text(
                    group.status,
                    style: TextStyle(
                      color: _getStatusColor(group.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (showLeaderActions)
                  PopupMenuButton<_GroupAction>(
                    enabled: actionsEnabled,
                    icon: const Icon(Icons.more_vert),
                    onSelected: (action) {
                      switch (action) {
                        case _GroupAction.updateInfo:
                          onEditInfo?.call();
                          break;
                        case _GroupAction.toggleType:
                          onToggleType?.call();
                          break;
                        case _GroupAction.completeGroup:
                          onCompleteGroup?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<_GroupAction>(
                        value: _GroupAction.updateInfo,
                        child: Text('Cập nhật thông tin'),
                      ),
                      PopupMenuItem<_GroupAction>(
                        value: _GroupAction.toggleType,
                        child: Text('Thay đổi trạng thái nhóm'),
                      ),
                      PopupMenuItem<_GroupAction>(
                        value: _GroupAction.completeGroup,
                        child: Text('Hoàn tất nhóm'),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              group.description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),

            const Divider(height: 32),

            // Info rows
            _buildInfoRow(
              Icons.school_outlined,
              'Học kỳ',
              group.semester?.name ?? 'Chưa có học kỳ',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.category_outlined,
              'Loại nhóm',
              group.type,
              valueColor: _getTypeColor(group.type),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              'Ngày tạo',
              _formatDate(group.createdAt),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.people_outline,
              'Số thành viên',
              '$memberCount người',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

enum _GroupAction { updateInfo, toggleType, completeGroup }
