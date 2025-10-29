import 'package:booking_group_flutter/features/home/presentation/pages/home_page.dart';
import 'package:booking_group_flutter/features/ideas/presentation/pages/ideas_page.dart';
import 'package:booking_group_flutter/features/notifications/application/notification_controller.dart';
import 'package:booking_group_flutter/features/notifications/presentation/pages/notification_page.dart';
import 'package:booking_group_flutter/features/profile/presentation/pages/profile_page.dart';
import 'package:booking_group_flutter/features/shell/presentation/widgets/rounded_bottom_navigation.dart';
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages;
  late final NotificationController _notificationController;

  @override
  void initState() {
    super.initState();
    _notificationController = NotificationController();
    _notificationController.loadNotifications();
    _pages = [
      const HomePage(),
      IdeasPage(
        onBack: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      NotificationPage(
        controller: _notificationController,
        onBack: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      ProfilePage(
        onBack: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
    ];
  }

  @override
  void dispose() {
    _notificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: AnimatedBuilder(
          animation: _notificationController,
          builder: (context, _) {
            final unreadCount = _notificationController.unreadCount;
            final navItems = [
              const RoundedNavItem(icon: Icons.home_outlined),
              const RoundedNavItem(icon: Icons.star_outline),
              RoundedNavItem(
                icon: unreadCount > 0
                    ? Icons.notifications
                    : Icons.notifications_none,
                badgeCount: unreadCount,
              ),
              const RoundedNavItem(icon: Icons.person_outline),
            ];

            return RoundedBottomNavigation(
              currentIndex: _currentIndex,
              items: navItems,
              onItemSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });

                if (index == 2) {
                  _notificationController
                      .markAllAsRead()
                      .catchError((error) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Không thể cập nhật thông báo: $error'),
                      ),
                    );
                  });
                }
              },
            );
          },
        ),
      ),
    );
  }
}
