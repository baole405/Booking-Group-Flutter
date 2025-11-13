import 'package:booking_group_flutter/features/ai_chat/presentation/pages/ai_chat_page.dart';
import 'package:booking_group_flutter/features/chat/presentation/pages/chat_page.dart';
import 'package:booking_group_flutter/features/home/presentation/pages/home_page.dart';
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

  late final PageController _pageController;
  late final List<Widget> _pages;
  late final NotificationController _notificationController;

  @override
  void initState() {
    super.initState();
    _notificationController = NotificationController();
    _pageController = PageController(initialPage: _currentIndex);
    _pages = [
      const HomePage(),
      const ChatPage(),
      const AiChatPage(),
      NotificationPage(controller: _notificationController),
      const ProfilePage(),
    ];
  }

  @override
  void dispose() {
    _notificationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _refreshNotifications() {
    _notificationController.loadNotifications().then((_) {
      if (_notificationController.errorMessage == null) {
        _notificationController.markAllAsRead().catchError((error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Khong the cap nhat thong bao: $error')),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
            });
          }
          if (index == 3) {
            _refreshNotifications();
          }
        },
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: AnimatedBuilder(
          animation: _notificationController,
          builder: (context, _) {
            final unreadCount = _notificationController.unreadCount;
            final navItems = [
              const RoundedNavItem(icon: Icons.home_outlined),
              const RoundedNavItem(icon: Icons.chat_bubble_outline),
              const RoundedNavItem(icon: Icons.smart_toy_outlined),
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
                if (_currentIndex == index) return;
                setState(() {
                  _currentIndex = index;
                });
                if (index == 3) {
                  _refreshNotifications();
                }
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
