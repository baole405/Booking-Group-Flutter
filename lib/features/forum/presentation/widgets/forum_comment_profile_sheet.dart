import 'package:booking_group_flutter/models/comment.dart';
import 'package:flutter/material.dart';

class ForumCommentProfileSheet extends StatelessWidget {
  final Comment comment;
  final bool canInvite;
  final bool isInviting;
  final bool isMember;
  final bool alreadyInvited;
  final bool isSelf;
  final VoidCallback? onInvite;

  const ForumCommentProfileSheet({
    super.key,
    required this.comment,
    required this.canInvite,
    required this.isInviting,
    required this.isMember,
    required this.alreadyInvited,
    required this.isSelf,
    this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    final user = comment.userResponse;
    final avatarUrl = user.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage:
                          hasAvatar ? NetworkImage(avatarUrl) : null,
                      child: !hasAvatar
                          ? Text(
                              user.fullName.isNotEmpty
                                  ? user.fullName.substring(0, 1).toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (user.major != null && user.major!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.school_outlined, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user.major!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  const Icon(Icons.badge_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.studentCode.isNotEmpty
                          ? user.studentCode
                          : 'Chưa có mã số',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (isSelf)
                const Text(
                  'Đây là tài khoản của bạn.',
                  style: TextStyle(color: Colors.grey),
                )
              else if (alreadyInvited)
                const Text(
                  'Bạn đã gửi lời mời đến sinh viên này.',
                  style: TextStyle(color: Colors.grey),
                )
              else if (isMember)
                const Text(
                  'Sinh viên này đã ở trong nhóm của bạn.',
                  style: TextStyle(color: Colors.grey),
                )
              else if (!canInvite)
                const Text(
                  'Bạn không có quyền mời sinh viên này.',
                  style: TextStyle(color: Colors.grey),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isInviting ? null : onInvite,
                    icon: isInviting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.person_add_alt_1_outlined),
                    label: Text(isInviting ? 'Đang gửi...' : 'Mời vào nhóm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
