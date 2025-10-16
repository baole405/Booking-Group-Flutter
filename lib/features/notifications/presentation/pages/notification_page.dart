import 'package:booking_group_flutter/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<_NotificationItem> _todayNotifications = [
    _NotificationItem(
      id: '1',
      title: 'Join Group Successfully',
      message: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
      timeLabel: '10:00 am',
      isUnread: true,
    ),
    _NotificationItem(
      id: '2',
      title: 'New Idea Notification',
      message: 'Lorem ipsum dolor sit amet.',
      timeLabel: '10:00 am',
      isUnread: true,
    ),
    _NotificationItem(
      id: '3',
      title: 'Your favorite group gonna over',
      message: 'Lorem ipsum dolor sit amet.',
      timeLabel: '09:00 am',
    ),
  ];

  final List<_NotificationItem> _previousNotifications = [
    _NotificationItem(
      id: '4',
      title: 'Late Return Warning',
      message:
          'Late Return Alert! Please return the car as soon as possible to avoid extra charges.',
      timeLabel: 'Yesterday',
    ),
    _NotificationItem(
      id: '5',
      title: 'Cancellation Notice',
      message: 'Your reservation has been cancelled successfully.',
      timeLabel: 'Yesterday',
    ),
    _NotificationItem(
      id: '6',
      title: 'Discount Notification',
      message: 'Congratulations! You unlocked a 10% discount on your rental.',
      timeLabel: 'Yesterday',
    ),
  ];

  bool _selectionMode = false;

  int get _totalUnread =>
      _todayNotifications.where((item) => item.isUnread).length +
      _previousNotifications.where((item) => item.isUnread).length;

  int get _selectedCount =>
      _todayNotifications.where((item) => item.isSelected).length +
      _previousNotifications.where((item) => item.isSelected).length;

  bool get _allSelected => _selectedCount > 0 &&
      _selectedCount ==
          (_todayNotifications.length + _previousNotifications.length);

  void _toggleSelectionMode([bool? value]) {
    setState(() {
      _selectionMode = value ?? !_selectionMode;
      if (!_selectionMode) {
        _clearSelections();
      }
    });
  }

  void _clearSelections() {
    for (final item in _todayNotifications) {
      item.isSelected = false;
    }
    for (final item in _previousNotifications) {
      item.isSelected = false;
    }
  }

  void _handleSelectItem(_NotificationItem item) {
    if (!_selectionMode) {
      setState(() {
        if (item.isUnread) item.isUnread = false;
      });
      return;
    }
    setState(() {
      item.isSelected = !item.isSelected;
      if (_selectedCount == 0) {
        _selectionMode = false;
      }
    });
  }

  void _selectAll(bool select) {
    setState(() {
      for (final item in _todayNotifications) {
        item.isSelected = select;
      }
      for (final item in _previousNotifications) {
        item.isSelected = select;
      }
      if (!select) {
        _selectionMode = false;
      } else {
        _selectionMode = true;
      }
    });
  }

  void _deleteSelected() {
    setState(() {
      _todayNotifications.removeWhere((item) => item.isSelected);
      _previousNotifications.removeWhere((item) => item.isSelected);
      if (_selectedCount == 0) {
        _selectionMode = false;
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected notifications removed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _NotificationsAppBar(
              onBack: widget.onBack,
              onMore: () => _toggleSelectionMode(true),
            ),
            if (_selectionMode) ...[
              _SelectionToolbar(
                allSelected: _allSelected,
                selectedCount: _selectedCount,
                onSelectAll: (value) => _selectAll(value ?? false),
                onDelete: _selectedCount > 0 ? _deleteSelected : null,
              ),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      title: 'Today',
                      subtitle:
                          '${_totalUnread.clamp(0, 99)} Unread Notification',
                    ),
                    const SizedBox(height: 16),
                    ..._todayNotifications.map(
                      (item) => _NotificationTile(
                        item: item,
                        selectionMode: _selectionMode,
                        onTap: () => _handleSelectItem(item),
                        onLongPress: () {
                          if (!_selectionMode) {
                            setState(() {
                              _selectionMode = true;
                              item.isSelected = true;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SectionHeader(
                      title: 'Previous',
                      subtitle: 'Older notifications',
                    ),
                    const SizedBox(height: 16),
                    ..._previousNotifications.map(
                      (item) => _NotificationTile(
                        item: item,
                        selectionMode: _selectionMode,
                        onTap: () => _handleSelectItem(item),
                        onLongPress: () {
                          if (!_selectionMode) {
                            setState(() {
                              _selectionMode = true;
                              item.isSelected = true;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  final _NotificationItem item;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: selectionMode && item.isSelected
            ? const Color.fromRGBO(31, 34, 37, 0.08)
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
                    ? _SelectionIndicator(
                        selected: item.isSelected,
                      )
                    : _NotificationIcon(
                        unread: item.isUnread,
                      ),
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
                            item.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item.timeLabel,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        if (item.isUnread)
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
                      item.message,
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

class _NotificationsAppBar extends StatelessWidget {
  const _NotificationsAppBar({
    this.onBack,
    required this.onMore,
  });

  final VoidCallback? onBack;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _RoundIconButton(
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
                onMore();
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
            child: const _RoundIconButton(
              icon: Icons.more_horiz,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionToolbar extends StatelessWidget {
  const _SelectionToolbar({
    required this.allSelected,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onDelete,
  });

  final bool allSelected;
  final int selectedCount;
  final ValueChanged<bool?> onSelectAll;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Checkbox(
            value: allSelected,
            onChanged: onSelectAll,
            shape: const CircleBorder(),
            activeColor: AppTheme.primaryDark,
          ),
          Text(
            'All',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          Text(
            '$selectedCount Selected',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 12),
          _RoundIconButton(
            icon: Icons.delete_outline,
            onTap: onDelete,
            disabled: onDelete == null,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.unread});

  final bool unread;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(unread),
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: unread ? AppTheme.primaryDark : Colors.white,
        border: Border.all(
          color: unread ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
      child: Icon(
        unread ? Icons.notifications_active : Icons.notifications_none,
        color: unread ? Colors.white : Colors.grey.shade700,
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(selected),
      height: 44,
      width: 44,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primaryDark,
      ),
      child: Icon(
        selected ? Icons.check : Icons.radio_button_unchecked,
        color: Colors.white,
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    this.onTap,
    this.disabled = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: disabled ? Colors.grey.shade300 : Colors.grey.shade100,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: disabled ? Colors.grey.shade500 : Colors.grey.shade800,
        ),
      ),
    );
  }
}

class _NotificationItem {
  _NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeLabel,
    this.isUnread = false,
  });

  final String id;
  final String title;
  final String message;
  final String timeLabel;
  bool isUnread;
  bool isSelected = false;
}

enum _NotificationMenu { select }
