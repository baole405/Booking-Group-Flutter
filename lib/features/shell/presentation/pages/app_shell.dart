import 'package:booking_group_flutter/features/home/presentation/pages/home_page.dart';
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

  final List<IconData> _icons = const [
    Icons.home_outlined,
    Icons.search,
    Icons.mail_outline,
    Icons.notifications_none,
    Icons.person_outline,
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const _PlaceholderPage(label: 'Search'),
      const _PlaceholderPage(label: 'Inbox'),
      NotificationPage(
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: RoundedBottomNavigation(
          currentIndex: _currentIndex,
          items: _icons,
          onItemSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          '$label screen coming soon',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
