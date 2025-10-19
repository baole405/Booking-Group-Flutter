import 'package:booking_group_flutter/app/theme/app_theme.dart';
import 'package:booking_group_flutter/models/group.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GroupRecommendationCard extends StatelessWidget {
  const GroupRecommendationCard({
    super.key,
    required this.group,
    this.onJoinTap,
  });

  final Group group;
  final VoidCallback? onJoinTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleParts = <String>[];
    final semesterName = group.semester?.name ?? '';
    if (semesterName.isNotEmpty) {
      subtitleParts.add(semesterName);
    }
    if (group.type.isNotEmpty) {
      subtitleParts.add(group.type);
    }
    final subtitleText = subtitleParts.join(' • ');

    final createdLabel = group.createdAt != null
        ? DateFormat.yMMMd().format(group.createdAt!.toLocal())
        : null;

    final chipLabels = <String>[];
    final status = group.status.replaceAll('_', ' ').toLowerCase();
    if (status.isNotEmpty) {
      chipLabels.add(
        status.split(' ').map(_capitalize).join(' '),
      );
    }
    if (createdLabel != null) {
      chipLabels.add('Created $createdLabel');
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  group.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.favorite_border,
                color: Colors.grey.shade500,
              ),
            ],
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
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: onJoinTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('View details'),
            ),
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
