import 'package:booking_group_flutter/features/home/presentation/widgets/section_card.dart';
import 'package:flutter/material.dart';

/// Section 2: Information Access
/// Grid 2 columns with 3 cards (Forum, Idea, Updating)
/// Last card centered if odd
class InformationAccessSection extends StatelessWidget {
  final VoidCallback onForumTap;
  final VoidCallback onIdeaTap;

  const InformationAccessSection({
    super.key,
    required this.onForumTap,
    required this.onIdeaTap,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      SectionCardData(
        title: 'Forum',
        subtitle: 'Thảo luận',
        icon: Icons.forum_outlined,
        backgroundColor: const Color(0xFF10B981), // Green
        iconColor: Colors.white,
        onTap: onForumTap,
      ),
      SectionCardData(
        title: 'Idea',
        subtitle: 'Ý tưởng',
        icon: Icons.lightbulb_outline,
        backgroundColor: const Color(0xFFF59E0B), // Amber
        iconColor: Colors.white,
        onTap: onIdeaTap,
      ),
      SectionCardData(
        title: 'Updating...',
        subtitle: 'Sắp ra mắt',
        icon: Icons.more_horiz,
        backgroundColor: const Color(0xFF6B7280), // Gray
        iconColor: Colors.white,
        onTap: () {
          // Do nothing for now
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          const Text(
            'Information Access',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Grid 2 columns with 3 cards
          // Using Wrap to auto-center the last card if odd
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: cards.map((card) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 44) / 2,
                height: (MediaQuery.of(context).size.width - 44) / 2,
                child: SectionCard(data: card),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
