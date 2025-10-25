import 'package:booking_group_flutter/models/idea.dart';
import 'package:flutter/material.dart';

import 'idea_card.dart';

class IdeasSection extends StatelessWidget {
  final List<Idea> ideas;
  final bool isLeader;
  final Function(Idea) onEditIdea;
  final Function(Idea) onDeleteIdea;
  final VoidCallback onCreateIdea;

  const IdeasSection({
    super.key,
    required this.ideas,
    required this.isLeader,
    required this.onEditIdea,
    required this.onDeleteIdea,
    required this.onCreateIdea,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Ý tưởng của nhóm (${ideas.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isLeader) ...[
                  ElevatedButton.icon(
                    onPressed: onCreateIdea,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tạo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(Icons.lightbulb_outline, color: Colors.grey.shade600),
              ],
            ),
            const SizedBox(height: 16),
            if (ideas.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chưa có ý tưởng nào',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ideas.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final idea = ideas[index];
                  return IdeaCard(
                    idea: idea,
                    isLeader: isLeader,
                    onEdit: () => onEditIdea(idea),
                    onDelete: () => onDeleteIdea(idea),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
