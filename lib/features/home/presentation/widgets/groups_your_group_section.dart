import 'package:booking_group_flutter/features/home/presentation/widgets/section_card.dart';
import 'package:flutter/material.dart';

/// Section 1: Groups and Your Group
/// Grid 2 columns with 2 cards
class GroupsYourGroupSection extends StatelessWidget {
  final VoidCallback onGroupsTap;
  final VoidCallback onYourGroupTap;

  const GroupsYourGroupSection({
    super.key,
    required this.onGroupsTap,
    required this.onYourGroupTap,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      SectionCardData(
        title: 'Groups',
        subtitle: 'Khám phá nhóm',
        icon: Icons.groups_outlined,
        backgroundColor: const Color(0xFF6366F1), // Indigo
        iconColor: Colors.white,
        onTap: onGroupsTap,
      ),
      SectionCardData(
        title: 'Your Group',
        subtitle: 'Nhóm của bạn',
        icon: Icons.group_outlined,
        backgroundColor: const Color(0xFF8B5CF6), // Purple
        iconColor: Colors.white,
        onTap: onYourGroupTap,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          const Text(
            'Groups and Your Group',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Grid 2 columns
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0, // Square cards
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              return SectionCard(data: cards[index]);
            },
          ),
        ],
      ),
    );
  }
}
