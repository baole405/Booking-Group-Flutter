import 'package:booking_group_flutter/features/ai_chat/models/ai_chat_attachments.dart';
import 'package:flutter/material.dart';

typedef GroupTapCallback = void Function(int groupId, {String? title});
typedef TeacherTapCallback = void Function(
  AiChatTeacherAttachment teacher,
);

class AiChatAttachmentsView extends StatelessWidget {
  const AiChatAttachmentsView({
    super.key,
    required this.attachments,
    this.onGroupTap,
    this.onTeacherTap,
  });

  final AiChatAttachmentBundle attachments;
  final GroupTapCallback? onGroupTap;
  final TeacherTapCallback? onTeacherTap;

  @override
  Widget build(BuildContext context) {
    if (!attachments.hasContent) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[];

    if (attachments.summary != null) {
      children.add(_SummaryCard(summary: attachments.summary!));
    }

    if (attachments.groups.isNotEmpty) {
      children.add(_GroupsCard(
        groups: attachments.groups,
        onGroupTap: onGroupTap,
      ));
    }

    if (attachments.teachers.isNotEmpty) {
      children.add(_TeachersCard(
        teachers: attachments.teachers,
        onTeacherTap: onTeacherTap,
      ));
    }

    if (attachments.members.isNotEmpty) {
      children.add(_MembersCard(members: attachments.members));
    }

    final spacedChildren = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i != children.length - 1) {
        spacedChildren.add(const SizedBox(height: 12));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        ...spacedChildren,
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final AiChatGroupSummaryAttachment summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: const Color(0xFFEEF2FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.groupTitle ?? 'Tình trạng nhóm của bạn',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4338CA),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (summary.status != null)
                  _SummaryChip(
                    icon: Icons.flag,
                    label: 'Trạng thái: ${summary.status}',
                  ),
                if (summary.memberCount != null)
                  _SummaryChip(
                    icon: Icons.people,
                    label: 'Thành viên: ${summary.memberCount}'
                        '${summary.memberLimit != null ? '/${summary.memberLimit}' : ''}',
                  ),
                if (summary.majorCount != null)
                  _SummaryChip(
                    icon: Icons.menu_book,
                    label: 'Chuyên ngành: ${summary.majorCount}',
                  ),
                if (summary.pendingRequests != null)
                  _SummaryChip(
                    icon: Icons.hourglass_bottom,
                    label: 'Yêu cầu chờ: ${summary.pendingRequests}',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFDCE0F5)),
    );
  }
}

class _GroupsCard extends StatelessWidget {
  const _GroupsCard({required this.groups, this.onGroupTap});

  final List<AiChatGroupAttachment> groups;
  final GroupTapCallback? onGroupTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          for (final group in groups)
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE0E7FF),
                child: Icon(Icons.groups, color: Color(0xFF4338CA)),
              ),
              title: Text(group.title),
              subtitle:
                  group.description != null ? Text(group.description!) : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: group.id > 0
                  ? () => onGroupTap?.call(group.id, title: group.title)
                  : null,
            ),
        ],
      ),
    );
  }
}

class _TeachersCard extends StatelessWidget {
  const _TeachersCard({required this.teachers, this.onTeacherTap});

  final List<AiChatTeacherAttachment> teachers;
  final TeacherTapCallback? onTeacherTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: teachers
          .map(
            (teacher) => Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: Color(0xFFFFF7ED),
                          child: Icon(Icons.support_agent, color: Color(0xFFFB923C)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                teacher.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                teacher.email,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (teacher.groupTitle != null)
                      Text(
                        'Nhóm phụ trách: ${teacher.groupTitle}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => onTeacherTap?.call(teacher),
                        icon: const Icon(Icons.forward_to_inbox),
                        label: const Text('Liên hệ / Xem nhóm'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MembersCard extends StatelessWidget {
  const _MembersCard({required this.members});

  final List<AiChatMemberAttachment> members;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thành viên liên quan',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: members
                  .map(
                    (member) => Chip(
                      avatar: member.avatarUrl != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(member.avatarUrl!),
                            )
                          : const CircleAvatar(
                              child: Icon(Icons.person, size: 16),
                            ),
                      label: Text(member.name),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
