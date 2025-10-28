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
    final avatarUrl = user.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final displayName = user.displayName;

    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
        child: !hasAvatar
            ? Text(
                user.avatarInitial,
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
                  displayName,
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
