import 'package:booking_group_flutter/features/groups/domain/group_models.dart';
import 'package:flutter/material.dart';

class GroupRecommendationCard extends StatelessWidget {
  const GroupRecommendationCard({
    super.key,
    required this.group,
    required this.onViewTap,
    this.onJoinTap,
    this.isJoining = false,
    this.isMember = false,
    this.hasGroup = false,
  });

  final GroupSummary group;
  final VoidCallback onViewTap;
  final VoidCallback? onJoinTap;
  final bool isJoining;
  final bool isMember;
  final bool hasGroup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleParts = <String>[];
    if (group.type?.isNotEmpty == true) {
      subtitleParts.add(group.type!);
    }
    if (group.status?.isNotEmpty == true) {
      subtitleParts.add(group.status!);
    }
    final subtitleText = subtitleParts.join(' • ');

    final chipLabels = <String>[];
    if (group.majorNames.isNotEmpty) {
      chipLabels.addAll(group.majorNames);
    }
    if (group.memberCount != null) {
      chipLabels.add('${group.memberCount} members');
    }

    final statusLabel = (group.status ?? '').replaceAll('_', ' ').trim();
    if (statusLabel.isNotEmpty && !chipLabels.contains(statusLabel)) {
      chipLabels.insert(0, statusLabel.split(' ').map(_capitalize).join(' '));
    }

    final isJoinDisabled = isMember || hasGroup || onJoinTap == null;
    String joinLabel;
    if (isMember) {
      joinLabel = 'Joined';
    } else if (hasGroup) {
      joinLabel = 'Join unavailable';
    } else {
      joinLabel = 'Join group';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 6),
            blurRadius: 16,
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onViewTap,
            child: Text(
              group.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            group.description?.trim().isNotEmpty == true
                ? group.description!.trim()
                : 'No description provided.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          if (subtitleText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitleText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
          if (chipLabels.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: chipLabels
                  .map(
                    (label) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const Spacer(),
          FilledButton(
            onPressed: isJoinDisabled || isJoining ? null : onJoinTap,
            child: isJoining
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(joinLabel),
          ),
          TextButton(
            onPressed: onViewTap,
            child: const Text('View details'),
          ),
        ],
      ),
    );
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
