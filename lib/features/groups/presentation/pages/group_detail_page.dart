import 'package:booking_group_flutter/features/groups/application/group_detail_controller.dart';
import 'package:booking_group_flutter/features/groups/data/group_repository.dart';
import 'package:booking_group_flutter/features/groups/domain/group_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:booking_group_flutter/features/groups/application/group_actions.dart';

class GroupDetailPage extends StatelessWidget {
  const GroupDetailPage({
    super.key,
    required this.groupId,
    this.initialSummary,
  });

  final int groupId;
  final GroupSummary? initialSummary;

  static Route<void> route({
    required int groupId,
    GroupSummary? initialSummary,
  }) {
    return MaterialPageRoute(
      builder: (_) => GroupDetailPage(
        groupId: groupId,
        initialSummary: initialSummary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupDetailController>(
      create: (context) => GroupDetailController(
        groupId: groupId,
        groupRepository: context.read<GroupRepository>(),
        groupActions: context.read<GroupActions>(),
        initialSummary: initialSummary,
      )..load(),
      child: const _GroupDetailView(),
    );
  }
}

class _GroupDetailView extends StatelessWidget {
  const _GroupDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group detail')),
      body: Consumer<GroupDetailController>(
        builder: (context, controller, _) {
          if (controller.isLoading && controller.detail == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null && controller.detail == null) {
            return _ErrorState(
              message: controller.errorMessage!,
              onRetry: controller.load,
            );
          }

          final summary = controller.summary;
          final detail = controller.detail;

          return RefreshIndicator(
            onRefresh: controller.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  summary?.title ?? 'Group',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  summary?.description?.trim().isNotEmpty == true
                      ? summary!.description!.trim()
                      : 'No description provided for this group.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (summary?.majorNames.isNotEmpty == true)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: summary!.majorNames
                        .map(
                          (major) => Chip(
                            label: Text(major),
                          ),
                        )
                        .toList(),
                  ),
                if (detail?.majors.isNotEmpty == true) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Major distribution',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...detail!.majors.map(
                    (major) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(major.majorName),
                      trailing: Text('${major.count}'),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Members',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (detail?.members.isEmpty == true)
                  const Text('No members have been listed yet.')
                else
                  ...detail!.members.map(
                    (member) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Text(member.displayName.isNotEmpty
                            ? member.displayName.substring(0, 1).toUpperCase()
                            : '?'),
                      ),
                      title: Text(member.displayName),
                      subtitle: Text(
                        [
                          member.role?.toLowerCase() == 'leader'
                              ? 'Leader'
                              : null,
                          member.majorName,
                        ].whereType<String>().join(' • '),
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                _JoinSection(controller: controller),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _JoinSection extends StatelessWidget {
  const _JoinSection({required this.controller});

  final GroupDetailController controller;

  @override
  Widget build(BuildContext context) {
    final isMember = controller.isMember;
    final hasGroup = controller.hasGroup;
    final isLoading = controller.isJoining;

    String buttonText;
    VoidCallback? onPressed;

    if (isMember) {
      buttonText = 'You are already in this group';
      onPressed = null;
    } else if (hasGroup) {
      buttonText = 'Leave current group to join a new one';
      onPressed = null;
    } else {
      buttonText = 'Join group';
      onPressed = () async {
        final message = await controller.joinGroup();
        if (!context.mounted) return;
        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      };
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(buttonText),
        ),
        if (hasGroup && !isMember)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'You already belong to a team. Leave your current group before joining another.',
              style: TextStyle(color: Colors.redAccent),
            ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
