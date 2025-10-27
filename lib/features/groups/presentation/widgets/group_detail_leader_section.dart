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
                    backgroundImage: leader!['avatarUrl'] != null
                        ? NetworkImage(leader!['avatarUrl'])
                        : null,
                    child: leader!['avatarUrl'] == null
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
                        if (leader!['major'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            leader!['major'],
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
