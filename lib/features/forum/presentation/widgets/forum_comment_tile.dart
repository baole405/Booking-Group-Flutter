import 'package:booking_group_flutter/models/comment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ForumCommentTile extends StatelessWidget {
  final Comment comment;
  final VoidCallback onProfileTap;
  final bool canInvite;
  final bool isMember;
  final bool alreadyInvited;

  const ForumCommentTile({
    super.key,
    required this.comment,
    required this.onProfileTap,
    required this.canInvite,
    required this.isMember,
    required this.alreadyInvited,
  });

  String _formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = comment.userResponse;

    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundImage:
            user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        child: user.avatarUrl == null
            ? Text(
                user.fullName.isNotEmpty
                    ? user.fullName.substring(0, 1).toUpperCase()
                    : '?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (user.major != null && user.major!.isNotEmpty)
                  Text(
                    user.major!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Text(
              _formatDate(comment.createdAt),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const Spacer(),
            TextButton(
              onPressed: onProfileTap,
              child: Text(
                canInvite
                    ? alreadyInvited
                        ? 'Đã mời'
                        : isMember
                            ? 'Đã trong nhóm'
                            : 'Xem hồ sơ'
                    : 'Xem hồ sơ',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
