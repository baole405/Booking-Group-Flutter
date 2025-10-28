import 'package:booking_group_flutter/models/post.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ForumPostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onViewGroup;
  final VoidCallback? onOpenComments;

  const ForumPostCard({
    super.key,
    required this.post,
    this.onViewGroup,
    this.onOpenComments,
  });

  Color _typeColor(String type) {
    switch (type.toUpperCase()) {
      case 'FIND_GROUP':
        return Colors.blue;
      case 'FIND_MEMBER':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _typeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'FIND_GROUP':
        return 'Tìm nhóm';
      case 'FIND_MEMBER':
        return 'Tìm thành viên';
      default:
        return type;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(post.type);
    final avatarUrl = post.userResponse.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      hasAvatar ? NetworkImage(avatarUrl) : null,
                  child: !hasAvatar
                      ? Text(
                          post.userResponse.fullName.isNotEmpty
                              ? post.userResponse.fullName
                                  .substring(0, 1)
                                  .toUpperCase()
                              : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userResponse.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDate(post.createdAt),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _typeLabel(post.type),
                    style: TextStyle(
                      color: typeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.content,
              style: const TextStyle(fontSize: 14),
            ),
            if (post.groupResponse != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.group,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        post.groupResponse!.title,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (onViewGroup != null)
                  TextButton.icon(
                    onPressed: onViewGroup,
                    icon: const Icon(Icons.group_outlined),
                    label: const Text('Xem nhóm'),
                  ),
                if (onViewGroup != null) const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: onOpenComments,
                  icon: const Icon(Icons.forum_outlined),
                  label: const Text('Bình luận'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
