import 'package:booking_group_flutter/models/group_member.dart';
import 'package:flutter/material.dart';

class GroupMemberProfileSheet extends StatelessWidget {
  const GroupMemberProfileSheet({
    super.key,
    required this.member,
    required this.isCurrentUser,
    required this.viewerIsLeader,
    this.onKickMember,
    this.isProcessing = false,
  });

  final GroupMember member;
  final bool isCurrentUser;
  final bool viewerIsLeader;
  final Future<void> Function()? onKickMember;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = member.avatarUrl;
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
                      backgroundImage: hasAvatar
                          ? NetworkImage(avatarUrl)
                          : null,
                      backgroundColor: const Color(
                        0xFF8B5CF6,
                      ).withValues(alpha: 0.1),
                      child: !hasAvatar
                          ? Text(
                              member.fullName.isNotEmpty
                                  ? member.fullName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B5CF6),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      member.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.email,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (member.studentCode != null && member.studentCode!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _InfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Student code',
                    value: member.studentCode!,
                  ),
                ),
              if (member.major?.name != null &&
                  member.major!.name.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _InfoRow(
                    icon: Icons.school_outlined,
                    label: 'Major',
                    value: member.major!.name,
                  ),
                ),
              _InfoRow(
                icon: Icons.account_circle_outlined,
                label: 'Role',
                value: member.role,
              ),
              const SizedBox(height: 24),
              if (isCurrentUser)
                const Text('This is you.', style: TextStyle(color: Colors.grey))
              else if (viewerIsLeader && onKickMember != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isProcessing || onKickMember == null
                        ? null
                        : () => onKickMember!.call(),
                    icon: isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.person_remove_alt_1_outlined),
                    label: Text(
                      isProcessing ? 'Removing...' : 'Remove from group',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red.shade700,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
