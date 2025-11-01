import 'package:booking_group_flutter/models/group_member.dart';
import 'package:booking_group_flutter/models/user_profile.dart';
import 'package:flutter/material.dart';

import 'member_card.dart';

class MembersSection extends StatelessWidget {
  const MembersSection({
    super.key,
    required this.members,
    this.leader,
    this.currentUserEmail,
    this.onMemberTap,
    this.interactionsDisabled = false,
  });

  final List<GroupMember> members;
  final UserProfile? leader;
  final String? currentUserEmail;
  final ValueChanged<GroupMember>? onMemberTap;
  final bool interactionsDisabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Members (${members.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.people, color: Colors.grey.shade600),
              ],
            ),
            const SizedBox(height: 16),
            if (members.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No members yet',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: members.length,
                separatorBuilder: (_, __) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final member = members[index];
                  final isCurrentUser =
                      currentUserEmail != null &&
                      currentUserEmail!.toLowerCase() ==
                          member.email.toLowerCase();

                  return MemberCard(
                    member: member,
                    leader: leader,
                    isCurrentUser: isCurrentUser,
                    enabled: !interactionsDisabled,
                    onTap: onMemberTap,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
