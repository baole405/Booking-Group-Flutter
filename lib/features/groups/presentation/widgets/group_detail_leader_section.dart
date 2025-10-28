import 'package:flutter/material.dart';

class GroupDetailLeaderSection extends StatelessWidget {
  final Map<String, dynamic>? leader;
  final String groupStatus;
  final bool isUserInGroup;
  final VoidCallback? onJoinAsLeader;

  const GroupDetailLeaderSection({
    super.key,
    required this.leader,
    required this.groupStatus,
    required this.isUserInGroup,
    this.onJoinAsLeader,
  });

  @override
  Widget build(BuildContext context) {
    final isFormingGroup = groupStatus.toUpperCase() == 'FORMING';
    final leaderAvatar = _extractAvatarUrl(leader?['avatarUrl']);
    final leaderMajor = _extractMajorName(leader?['major']);
    final hasAvatar = leaderAvatar != null && leaderAvatar.isNotEmpty;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trưởng nhóm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (leader == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nhóm chưa có trưởng nhóm',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      // Show join button if FORMING and user not in group
                      if (isFormingGroup && !isUserInGroup) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: onJoinAsLeader,
                            icon: const Icon(Icons.how_to_reg),
                            label: const Text('Tham gia nhóm'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B5CF6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage:
                        hasAvatar ? NetworkImage(leaderAvatar) : null,
                    child: !hasAvatar
                        ? Text(
                            (leader!['fullName'] ?? '?')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leader!['fullName'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          leader!['studentCode'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (leaderMajor != null && leaderMajor.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            leaderMajor,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

String? _extractAvatarUrl(dynamic avatar) {
  if (avatar == null) {
    return null;
  }

  if (avatar is String && avatar.isNotEmpty) {
    return avatar;
  }

  if (avatar is Map<String, dynamic>) {
    final candidates = [
      avatar['url'],
      avatar['signedUrl'],
      avatar['path'],
      avatar['value'],
    ];

    for (final candidate in candidates) {
      if (candidate is String && candidate.isNotEmpty) {
        return candidate;
      }
    }
  }

  return null;
}

String? _extractMajorName(dynamic major) {
  if (major == null) {
    return null;
  }

  if (major is String && major.isNotEmpty) {
    return major;
  }

  if (major is Map<String, dynamic>) {
    final name = major['name'];
    if (name is String && name.isNotEmpty) {
      return name;
    }
  }

  return null;
}
