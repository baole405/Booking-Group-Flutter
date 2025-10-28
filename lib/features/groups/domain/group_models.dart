class GroupSummary {
  const GroupSummary({
    required this.id,
    required this.title,
    this.description,
    this.type,
    this.status,
    this.memberCount,
    this.majorNames = const <String>[],
  });

  final int id;
  final String title;
  final String? description;
  final String? type;
  final String? status;
  final int? memberCount;
  final List<String> majorNames;

  factory GroupSummary.fromJson(Map<String, dynamic> json) {
    return GroupSummary(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? json['name'] as String? ?? 'Untitled group',
      description: json['description'] as String?,
      type: json['type'] as String?,
      status: json['status'] as String?,
      memberCount: (json['memberCount'] as num?)?.toInt() ??
          (json['membersCount'] as num?)?.toInt(),
      majorNames: _parseMajorNames(json),
    );
  }

  GroupSummary copyWith({
    String? description,
    String? type,
    String? status,
    int? memberCount,
    List<String>? majorNames,
  }) {
    return GroupSummary(
      id: id,
      title: title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      memberCount: memberCount ?? this.memberCount,
      majorNames: majorNames ?? this.majorNames,
    );
  }

  static List<String> _parseMajorNames(Map<String, dynamic> json) {
    final majorsRaw = json['majors'] ??
        json['majorResponses'] ??
        json['majorNames'] ??
        json['majorsResponse'];
    if (majorsRaw is List) {
      return majorsRaw
          .map((item) {
            if (item is Map<String, dynamic>) {
              return item['name'] as String? ??
                  item['majorName'] as String? ??
                  item['code'] as String?;
            }
            if (item is String) return item;
            return null;
          })
          .whereType<String>()
          .toList();
    }
    return const <String>[];
  }
}

class GroupDetail {
  const GroupDetail({
    required this.summary,
    this.members = const <GroupMember>[],
    this.majors = const <GroupMajorCount>[],
    this.leader,
  });

  final GroupSummary summary;
  final List<GroupMember> members;
  final List<GroupMajorCount> majors;
  final GroupMember? leader;

  GroupDetail copyWith({
    GroupSummary? summary,
    List<GroupMember>? members,
    List<GroupMajorCount>? majors,
    GroupMember? leader,
  }) {
    return GroupDetail(
      summary: summary ?? this.summary,
      members: members ?? this.members,
      majors: majors ?? this.majors,
      leader: leader ?? this.leader,
    );
  }
}

class GroupMember {
  const GroupMember({
    required this.id,
    required this.displayName,
    this.majorName,
    this.role,
  });

  final int id;
  final String displayName;
  final String? majorName;
  final String? role;

  bool get isLeader => (role ?? '').toUpperCase() == 'LEADER';

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: (json['id'] as num?)?.toInt() ?? 0,
      displayName: json['fullName'] as String? ??
          json['name'] as String? ??
          json['displayName'] as String? ??
          'Member',
      majorName: json['majorName'] as String? ??
          (json['major'] is Map<String, dynamic>
              ? (json['major']['name'] as String? ?? json['major']['code'] as String?)
              : json['major'] as String?),
      role: json['role'] as String? ??
          json['membershipRole'] as String? ??
          json['memberRole'] as String?,
    );
  }
}

class GroupMajorCount {
  const GroupMajorCount({
    required this.majorName,
    required this.count,
  });

  final String majorName;
  final int count;

  factory GroupMajorCount.fromJson(Map<String, dynamic> json) {
    return GroupMajorCount(
      majorName: json['majorName'] as String? ??
          json['name'] as String? ??
          json['major'] as String? ??
          'Unknown',
      count: (json['count'] as num?)?.toInt() ??
          (json['quantity'] as num?)?.toInt() ??
          (json['total'] as num?)?.toInt() ??
          0,
    );
  }
}
