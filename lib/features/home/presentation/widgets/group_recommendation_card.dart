import 'package:booking_group_flutter/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class GroupRecommendationCard extends StatelessWidget {
  const GroupRecommendationCard({
    super.key,
    required this.title,
    required this.needText,
    required this.tags,
    required this.rating,
  });

  final String title;
  final String needText;
  final String tags;
  final double rating;

  @override
  Widget build(BuildContext context) {
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
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Icon(
                Icons.favorite_border,
                color: Colors.grey.shade500,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            needText,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 6),
          Text(
            tags,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey.shade500),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber.shade600, size: 18),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDark,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Join now'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
