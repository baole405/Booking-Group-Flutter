import 'package:booking_group_flutter/app/theme/app_theme.dart';
import 'package:booking_group_flutter/features/auth/application/session_controller.dart';
import 'package:booking_group_flutter/features/groups/application/group_actions.dart';
import 'package:booking_group_flutter/features/groups/data/group_repository.dart';
import 'package:booking_group_flutter/features/groups/domain/group_models.dart';
import 'package:booking_group_flutter/features/groups/presentation/pages/group_detail_page.dart';
import 'package:booking_group_flutter/features/home/application/home_controller.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/group_recommendation_card.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/major_group_card.dart';
import 'package:booking_group_flutter/features/home/presentation/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeController>(
      create: (context) => HomeController(
        groupRepository: context.read<GroupRepository>(),
        groupActions: context.read<GroupActions>(),
      )..loadGroups(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<HomeController>(
          builder: (context, controller, _) {
            return RefreshIndicator(
              onRefresh: controller.loadGroups,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      onLogoutTap: () => context.read<SessionController>().signOut(),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Search your dream team...',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _SearchField(onTapFilter: () {}),
                    const SizedBox(height: 24),
                    _GroupSection(controller: controller),
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
            );
          },
        ),
      ),
    );
  }
}

class _GroupSection extends StatelessWidget {
  const _GroupSection({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && controller.groups.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.errorMessage != null && controller.groups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: _ErrorState(
          message: controller.errorMessage!,
          onRetry: controller.loadGroups,
        ),
      );
    }
    if (controller.groups.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: _EmptyState(),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.groups.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final group = controller.groups[index];
        return GroupRecommendationCard(
          group: group,
          onViewTap: () => _openGroupDetail(context, group),
          onJoinTap: controller.hasGroup
              ? null
              : () async {
                  final message = await controller.joinGroup(group);
                  if (!context.mounted) return;
                  if (message != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  }
                },
          isJoining: controller.isJoining(group.id),
          isMember: controller.isMemberOf(group),
          hasGroup: controller.hasGroup,
        );
      },
    );
  }

  void _openGroupDetail(BuildContext context, GroupSummary group) {
    Navigator.of(context).push(
      GroupDetailPage.route(groupId: group.id, initialSummary: group),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello,',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Ready to collaborate?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: onLogoutTap,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }
}

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
              hintText: 'Search group, majors, etc.',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onTapFilter,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryDark,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.tune, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.group_outlined, size: 48, color: Colors.grey),
        const SizedBox(height: 12),
        Text(
          'No groups available right now.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Check back later or adjust your filters.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
        const SizedBox(height: 12),
        Text(
          message,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: onRetry,
          child: const Text('Retry'),
        ),
      ],
    );
  }
}

class _MajorGroupInfo {
  const _MajorGroupInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

const _majorGroups = <_MajorGroupInfo>[
  _MajorGroupInfo(
    title: 'Software Engineering',
    subtitle: '28 open teams',
    icon: Icons.computer_outlined,
  ),
  _MajorGroupInfo(
    title: 'Business Analytics',
    subtitle: '12 open teams',
    icon: Icons.bar_chart_outlined,
  ),
  _MajorGroupInfo(
    title: 'Information Security',
    subtitle: '8 open teams',
    icon: Icons.security_outlined,
  ),
];
