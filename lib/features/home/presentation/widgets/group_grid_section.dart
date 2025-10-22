import 'package:booking_group_flutter/features/home/presentation/widgets/group_card.dart';
import 'package:booking_group_flutter/models/group.dart';
import 'package:flutter/material.dart';

/// Grid section for displaying groups
class GroupGridSection extends StatelessWidget {
  final String title;
  final List<Group> groups;
  final VoidCallback? onViewAll;
  final Function(Group)? onGroupTap;
  final Function(Group)? onGroupJoin;
  final Function(Group)? onGroupFavorite;

  const GroupGridSection({
    super.key,
    required this.title,
    required this.groups,
    this.onViewAll,
    this.onGroupTap,
    this.onGroupJoin,
    this.onGroupFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(onPressed: onViewAll, child: const Text('View All')),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Group cards
        if (groups.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'No groups found',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9, // Adjusted for better fit
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: groups.length > 4 ? 4 : groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return GroupCard(
                group: group,
                onTap: () => onGroupTap?.call(group),
                onJoin: () => onGroupJoin?.call(group),
                onFavorite: () => onGroupFavorite?.call(group),
              );
            },
          ),
      ],
    );
  }
}
