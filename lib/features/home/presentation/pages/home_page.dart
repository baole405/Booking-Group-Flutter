import 'package:booking_group_flutter/app/theme/app_theme.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/group_recommendation_card.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/major_group_card.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/section_header.dart';
import 'package:booking_group_flutter/models/group.dart';
import 'package:booking_group_flutter/resources/group_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GroupApi _groupApi = const GroupApi();
  late Future<List<Group>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _groupApi.fetchGroups();
  }

  Future<void> _handleLogout() async {
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      debugPrint('Google sign out error: $e');
    }
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout: $e')),
      );
    }
  }

  Future<void> _refreshGroups() async {
    final future = _groupApi.fetchGroups();
    setState(() {
      _groupsFuture = future;
    });
    try {
      await future;
    } catch (_) {
      // Errors are surfaced through the FutureBuilder in the UI.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshGroups,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  onLogoutTap: _handleLogout,
                ),
                const SizedBox(height: 28),
                Text(
                  'Search your dream team...',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _SearchField(onTapFilter: () {}),
                const SizedBox(height: 24),
                FutureBuilder<List<Group>>(
                  future: _groupsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: _ErrorState(onRetry: _refreshGroups),
                      );
                    }
                    final groups = snapshot.data ?? const <Group>[];
                    if (groups.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: _EmptyState(),
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: groups.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.82,
                      ),
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return GroupRecommendationCard(
                          group: group,
                          onJoinTap: () {},
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
                SectionHeader(
                  title: 'Relative to your major',
                  onActionTap: () {},
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _majorGroups.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final group = _majorGroups[index];
                      return MajorGroupCard(
                        title: group.title,
                        subtitle: group.subtitle,
                        icon: group.icon,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onLogoutTap,
  });

  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 44, height: 44),
        Expanded(
          child: Center(
            child: Image.asset(
              'assets/logo_fptu.png',
              height: 72,
            ),
          ),
        ),
        PopupMenuButton<_MenuAction>(
          onSelected: (value) {
            if (value == _MenuAction.logout) {
              onLogoutTap();
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          offset: const Offset(0, 46),
          itemBuilder: (context) => [
            PopupMenuItem<_MenuAction>(
              value: _MenuAction.logout,
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.grey.shade700, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Logout',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade100,
            ),
            child: Icon(
              Icons.more_horiz,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}

enum _MenuAction { logout }

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTapFilter});

  final VoidCallback onTapFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search your dream team...',
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onTapFilter,
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryDark,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.tune,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 36),
          const SizedBox(height: 12),
          Text(
            'Không tải được danh sách nhóm.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              onRetry();
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.groups_outlined, color: Colors.grey.shade500, size: 36),
          const SizedBox(height: 12),
          Text(
            'Chưa có nhóm nào trong hệ thống.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _MajorInfo {
  const _MajorInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

const List<_MajorInfo> _majorGroups = [
  _MajorInfo(
    title: 'Group 13',
    subtitle: '4 IT',
    icon: Icons.group,
  ),
  _MajorInfo(
    title: 'Group 21',
    subtitle: '3 MC',
    icon: Icons.people_alt_outlined,
  ),
  _MajorInfo(
    title: 'Group Sigma',
    subtitle: '4 Dev',
    icon: Icons.code,
  ),
];
