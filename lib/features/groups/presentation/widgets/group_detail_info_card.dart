import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GroupDetailInfoCard extends StatelessWidget {
  final Map<String, dynamic> groupDetail;
  final int memberCount;

  const GroupDetailInfoCard({
    super.key,
    required this.groupDetail,
    required this.memberCount,
  });

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'FORMING':
        return Colors.orange;
      case 'ACTIVE':
        return Colors.green;
      case 'COMPLETED':
        return Colors.blue;
      case 'DISBANDED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status?.toUpperCase()) {
      case 'FORMING':
        return 'Đang tạo';
      case 'ACTIVE':
        return 'Hoạt động';
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'DISBANDED':
        return 'Giải tán';
      default:
        return status ?? 'N/A';
    }
  }

  Color _getTypeColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'PUBLIC':
        return Colors.blue;
      case 'PRIVATE':
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
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

  @override
  Widget build(BuildContext context) {
    // Safe getters with type checking
    String getStringValue(dynamic value, [String defaultValue = '']) {
      if (value == null) return defaultValue;
      if (value is String) return value;
      if (value is Map) return value['name']?.toString() ?? defaultValue;
      return value.toString();
    }

    final title = getStringValue(groupDetail['title'], 'N/A');
    final description = getStringValue(
      groupDetail['description'],
      'Không có mô tả',
    );
    final status = getStringValue(groupDetail['status'], '');
    final type = getStringValue(groupDetail['type'], 'N/A');
    final createdAt = getStringValue(groupDetail['createdAt'], '');
    final semesterName = groupDetail['semester'] != null
        ? getStringValue(groupDetail['semester']['name'], 'N/A')
        : 'N/A';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(status),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
            ),
            const Divider(height: 32),
            _buildInfoRow(Icons.school, 'Học kỳ', semesterName),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.category,
              'Loại',
              type,
              valueColor: _getTypeColor(type),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              'Ngày tạo',
              _formatDate(createdAt),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.people, 'Thành viên', '$memberCount người'),
          ],
        ),
      ),
    );
  }
}
