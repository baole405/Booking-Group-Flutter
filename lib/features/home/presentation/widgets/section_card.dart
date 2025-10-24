import 'package:flutter/material.dart';

/// Model for Section Card data
class SectionCardData {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const SectionCardData({
    required this.title,
    this.subtitle,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    required this.onTap,
  });
}

/// Reusable card widget for both Section 1 and Section 2
class SectionCard extends StatelessWidget {
  final SectionCardData data;

  const SectionCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: data.backgroundColor != null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      data.backgroundColor!.withOpacity(0.8),
                      data.backgroundColor!,
                    ],
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      data.iconColor?.withOpacity(0.1) ??
                      Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  data.icon,
                  size: 40,
                  color: data.iconColor ?? Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: data.backgroundColor != null
                      ? Colors.white
                      : Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),

              // Subtitle (if provided)
              if (data.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  data.subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: data.backgroundColor != null
                        ? Colors.white.withOpacity(0.9)
                        : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
