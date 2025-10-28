import 'package:booking_group_flutter/core/network/backend_client.dart';
import 'package:booking_group_flutter/features/groups/domain/group_models.dart';

class GroupRepository {
  const GroupRepository({required BackendClient client}) : _client = client;

  final BackendClient _client;

  Future<List<GroupSummary>> fetchAvailableGroups() async {
    final response = await _client.get('/groups/available');
    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => GroupSummary.fromJson(
                Map<String, dynamic>.from(item.cast<String, dynamic>()),
              ))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final content = data['content'];
      if (content is List) {
        return content
            .whereType<Map>()
            .map((item) => GroupSummary.fromJson(
                  Map<String, dynamic>.from(item.cast<String, dynamic>()),
                ))
            .toList();
      }
    }
    return const <GroupSummary>[];
  }

  Future<GroupDetail> fetchGroupDetail(int groupId) async {
    final detailResponse = await _client.get('/groups/$groupId');
    final detailRaw = detailResponse.data;
    final summary = GroupSummary.fromJson(
      detailRaw is Map<String, dynamic>
          ? Map<String, dynamic>.from(detailRaw)
          : <String, dynamic>{},
    );

    final membersResponse = await _client.get('/groups/$groupId/members');
    final majorsResponse = await _client.get('/groups/$groupId/majors');
    final leaderResponse = await _client.get('/groups/$groupId/leader');

    final members = <GroupMember>[];
    final membersData = membersResponse.data;
    if (membersData is List) {
      members.addAll(
        membersData.map(
          (item) => GroupMember.fromJson(
            item is Map<String, dynamic>
                ? Map<String, dynamic>.from(item)
                : <String, dynamic>{},
          ),
        ),
      );
    }

    final majors = <GroupMajorCount>[];
    final majorsData = majorsResponse.data;
    if (majorsData is List) {
      majors.addAll(
        majorsData.map(
          (item) => GroupMajorCount.fromJson(
            item is Map<String, dynamic>
                ? Map<String, dynamic>.from(item)
                : <String, dynamic>{},
          ),
        ),
      );
    }

    GroupMember? leader;
    final leaderData = leaderResponse.data;
    if (leaderData is Map<String, dynamic>) {
      leader = GroupMember.fromJson(leaderData);
    }

    return GroupDetail(
      summary: summary,
      members: members,
      majors: majors,
      leader: leader ?? members.firstWhere(
        (member) => member.isLeader,
        orElse: () => members.isEmpty
            ? const GroupMember(id: 0, displayName: 'Leader', role: 'LEADER')
            : members.first,
      ),
    );
  }

  Future<String> joinGroup(int groupId) async {
    final response = await _client.post('/joins/$groupId');
    return response.message ?? 'Join request submitted';
  }
}
