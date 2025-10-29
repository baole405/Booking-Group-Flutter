import 'package:booking_group_flutter/features/notifications/application/notification_controller.dart';
import 'package:booking_group_flutter/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:booking_group_flutter/features/notifications/presentation/widgets/notifications_app_bar.dart';
import 'package:booking_group_flutter/features/notifications/presentation/widgets/section_header.dart';
import 'package:booking_group_flutter/features/notifications/presentation/widgets/selection_toolbar.dart';
import 'package:booking_group_flutter/models/app_notification.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({
    super.key,
    this.onBack,
    required this.controller,
  });

  final VoidCallback? onBack;
  final NotificationController controller;

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _selectionMode = false;
  final Set<int> _selectedIds = <int>{};

  @override
  void initState() {
    super.initState();
    if (!widget.controller.initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.loadNotifications();
      });
    }
  }

  @override
  void didUpdateWidget(covariant NotificationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller &&
        !widget.controller.initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.loadNotifications();
      });
    }
  }

  void _toggleSelectionMode([bool? value]) {
    setState(() {
      _selectionMode = value ?? !_selectionMode;
      if (!_selectionMode) {
        _selectedIds.clear();
      }
    });
  }

  void _toggleSelection(AppNotification notification) {
    if (!_selectionMode) {
      widget.controller.markNotificationAsRead(notification).catchError((error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể đánh dấu đã đọc: $error')),
        );
      });
      return;
    }

    setState(() {
      if (_selectedIds.contains(notification.id)) {
        _selectedIds.remove(notification.id);
      } else {
        _selectedIds.add(notification.id);
      }
      if (_selectedIds.isEmpty) {
        _selectionMode = false;
      }
    });
  }

  void _handleLongPress(AppNotification notification) {
    if (_selectionMode) return;
    setState(() {
      _selectionMode = true;
      _selectedIds.add(notification.id);
    });
  }

  void _handleDeleteSelected() {
    if (_selectedIds.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng xóa thông báo sẽ được cập nhật sau.'),
      ),
    );
  }

  bool get _allSelected =>
      _selectedIds.isNotEmpty &&
      widget.controller.notifications
          .every((notification) => _selectedIds.contains(notification.id));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            final notifications = widget.controller.notifications;
            final unreadCount = widget.controller.unreadCount;

            final todayNotifications = notifications
                .where((notification) =>
                    _isSameDay(notification.createdAt, DateTime.now()))
                .toList();
            final previousNotifications = notifications
                .where((notification) =>
                    !_isSameDay(notification.createdAt, DateTime.now()))
                .toList();

            return Column(
              children: [
                NotificationsAppBar(
                  onBack: widget.onBack,
                  onSelectMode: () => _toggleSelectionMode(true),
                ),
                if (_selectionMode)
                  SelectionToolbar(
                    allSelected: _allSelected,
                    selectedCount: _selectedIds.length,
                    onSelectAll: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedIds
                            ..clear()
                            ..addAll(notifications.map((n) => n.id));
                        } else {
                          _selectedIds.clear();
                          _selectionMode = false;
                        }
                      });
                    },
                    onDelete: _selectedIds.isEmpty ? null : _handleDeleteSelected,
                  ),
                if (_selectionMode) const SizedBox(height: 12),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => widget.controller.refreshNotifications(),
                    child: _buildContent(
                      context,
                      todayNotifications,
                      previousNotifications,
                      unreadCount,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<AppNotification> todayNotifications,
    List<AppNotification> previousNotifications,
    int unreadCount,
  ) {
    if (widget.controller.isLoading && !widget.controller.initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.controller.errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Center(
            child: Text(
              widget.controller.errorMessage!,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton(
              onPressed: widget.controller.loadNotifications,
              child: const Text('Thử lại'),
            ),
          ),
        ],
      );
    }

    if (todayNotifications.isEmpty && previousNotifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.notifications_none,
              size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Không có thông báo nào',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Bạn sẽ nhận thông báo khi có hoạt động mới.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 80),
        ],
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (todayNotifications.isNotEmpty) ...[
            NotificationSectionHeader(
              title: 'Today',
              subtitle: '${unreadCount.clamp(0, 99)} Unread Notification',
            ),
            const SizedBox(height: 16),
            ...todayNotifications.map(
              (notification) => NotificationTile(
                notification: notification,
                timeLabel: _formatTimeLabel(notification),
                selectionMode: _selectionMode,
                selected: _selectedIds.contains(notification.id),
                onTap: () => _toggleSelection(notification),
                onLongPress: () => _handleLongPress(notification),
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (previousNotifications.isNotEmpty) ...[
            NotificationSectionHeader(
              title: 'Previous',
              subtitle: 'Older notifications',
            ),
            const SizedBox(height: 16),
            ...previousNotifications.map(
              (notification) => NotificationTile(
                notification: notification,
                timeLabel: _formatTimeLabel(notification),
                selectionMode: _selectionMode,
                selected: _selectedIds.contains(notification.id),
                onTap: () => _toggleSelection(notification),
                onLongPress: () => _handleLongPress(notification),
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (widget.controller.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime? source, DateTime target) {
    if (source == null) return false;
    return source.year == target.year &&
        source.month == target.month &&
        source.day == target.day;
  }

  String _formatTimeLabel(AppNotification notification) {
    final createdAt = notification.createdAt;
    if (createdAt == null) {
      return '';
    }

    final now = DateTime.now();
    if (_isSameDay(createdAt, now)) {
      return DateFormat('HH:mm').format(createdAt);
    }

    final difference = now.difference(createdAt).inDays;
    if (difference == 1) {
      return 'Yesterday';
    }

    if (difference < 7) {
      return DateFormat.E().format(createdAt);
    }

    return DateFormat('dd/MM/yyyy').format(createdAt);
  }
}
