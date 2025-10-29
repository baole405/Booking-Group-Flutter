import 'package:flutter/material.dart';

class NotificationsAppBar extends StatelessWidget {
  const NotificationsAppBar({
    super.key,
    this.onBack,
    required this.onSelectMode,
  });

  final VoidCallback? onBack;
  final VoidCallback onSelectMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          RoundIconButton(
            icon: Icons.arrow_back_ios_new,
            onTap: onBack,
          ),
          Expanded(
            child: Center(
              child: Text(
                'Notification',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          PopupMenuButton<_NotificationMenu>(
            onSelected: (value) {
              if (value == _NotificationMenu.select) {
                onSelectMode();
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              PopupMenuItem<_NotificationMenu>(
                value: _NotificationMenu.select,
                child: Row(
                  children: [
                    Icon(Icons.done_all, color: Colors.grey.shade700, size: 20),
                    const SizedBox(width: 12),
                    const Text('Select notifications'),
                  ],
                ),
              ),
            ],
            child: const RoundIconButton(
              icon: Icons.more_horiz,
            ),
          ),
        ],
      ),
    );
  }
}

enum _NotificationMenu { select }

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 20, color: Colors.grey.shade700),
      ),
    );
  }
}
