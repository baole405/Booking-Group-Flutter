import 'package:booking_group_flutter/models/group_member.dart';
import 'package:booking_group_flutter/models/user_profile.dart';
import 'package:flutter/material.dart';

class MemberCard extends StatelessWidget {
  const MemberCard({
    super.key,
    required this.member,
    this.leader,
    this.isCurrentUser = false,
    this.onTap,
    this.enabled = true,
  });

  final GroupMember member;
  final UserProfile? leader;
  final bool isCurrentUser;
  final ValueChanged<GroupMember>? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool isLeader = leader?.email == member.email;
    final avatarUrl = member.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return InkWell(
      onTap: enabled && onTap != null ? () => onTap!(member) : null,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
            child: !hasAvatar
                ? Text(
                    member.fullName.isNotEmpty
                        ? member.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5CF6),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isLeader)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Leader',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Flexible(
                      child: Text(
                        member.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  member.major?.name ?? 'Major not available',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (member.studentCode != null && member.studentCode!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                member.studentCode!,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Tooltip(
                message: 'You',
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B5CF6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
