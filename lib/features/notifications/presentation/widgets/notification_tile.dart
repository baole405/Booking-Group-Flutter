import 'package:booking_group_flutter/app/theme/app_theme.dart';
import 'package:booking_group_flutter/models/app_notification.dart';
import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.timeLabel,
    required this.selectionMode,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final AppNotification notification;
  final String timeLabel;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: selectionMode && selected
            ? AppTheme.primaryDark.withOpacity(0.08)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: selectionMode
                    ? SelectionIndicator(selected: selected)
                    : NotificationLeadingIcon(unread: notification.isUnread),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          timeLabel,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        if (notification.isUnread)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            height: 8,
                            width: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF3366FF),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.message,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationLeadingIcon extends StatelessWidget {
  const NotificationLeadingIcon({super.key, required this.unread});

  final bool unread;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: unread
            ? const Color.fromRGBO(51, 102, 255, 0.12)
            : Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Icon(
        unread ? Icons.notifications_active : Icons.notifications_none,
        color: unread ? const Color(0xFF3366FF) : Colors.grey.shade600,
        size: 22,
      ),
    );
  }
}

class SelectionIndicator extends StatelessWidget {
  const SelectionIndicator({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? const Color(0xFF3366FF) : Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3366FF) : Colors.transparent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
