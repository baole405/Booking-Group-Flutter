import 'dart:convert';

class AiChatAttachmentBundle {
  const AiChatAttachmentBundle({
    this.groups = const [],
    this.teachers = const [],
    this.members = const [],
    this.summary,
    this.raw = const {},
  });

  final List<AiChatGroupAttachment> groups;
  final List<AiChatTeacherAttachment> teachers;
  final List<AiChatMemberAttachment> members;
  final AiChatGroupSummaryAttachment? summary;
  final Map<String, dynamic> raw;

  bool get hasContent =>
      groups.isNotEmpty ||
      teachers.isNotEmpty ||
      members.isNotEmpty ||
      (summary?.hasData ?? false);

  Map<String, dynamic> toJson() => {
        if (groups.isNotEmpty) 'groups': groups.map((g) => g.toJson()).toList(),
        if (teachers.isNotEmpty)
          'teachers': teachers.map((t) => t.toJson()).toList(),
        if (members.isNotEmpty)
          'members': members.map((m) => m.toJson()).toList(),
        if (summary != null && summary!.hasData) 'summary': summary!.toJson(),
        if (raw.isNotEmpty) 'raw': raw,
      };

  factory AiChatAttachmentBundle.fromJson(dynamic data) {
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {
        data = null;
      }
    }

    if (data is! Map<String, dynamic>) {
      return const AiChatAttachmentBundle();
    }

    List<T> _parseList<T>(
      dynamic value,
      T Function(Map<String, dynamic>) builder,
    ) {
      if (value is List) {
        return value
            .whereType<Map<String, dynamic>>()
            .map(builder)
            .toList(growable: false);
      }
      return const [];
    }

    final groups = _parseList(
      data['groups'],
      AiChatGroupAttachment.fromJson,
    );

    final teachers = _parseList(
      data['teachers'],
      AiChatTeacherAttachment.fromJson,
    );

    final members = _parseList(
      data['members'],
      AiChatMemberAttachment.fromJson,
    );

    final summary = AiChatGroupSummaryAttachment.fromJson(data);

    final raw = Map<String, dynamic>.from(data);

    return AiChatAttachmentBundle(
      groups: groups,
      teachers: teachers,
      members: members,
      summary: summary.hasData ? summary : null,
      raw: raw,
    );
  }

  AiChatAttachmentBundle merge(AiChatAttachmentBundle other) {
    return AiChatAttachmentBundle(
      groups: [...groups, ...other.groups],
      teachers: [...teachers, ...other.teachers],
      members: [...members, ...other.members],
      summary: summary ?? other.summary,
      raw: {...raw, ...other.raw},
    );
  }
}

class AiChatGroupAttachment {
  const AiChatGroupAttachment({
    required this.id,
    required this.title,
    this.description,
  });

  final int id;
  final String title;
  final String? description;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (description != null) 'description': description,
      };

  factory AiChatGroupAttachment.fromJson(Map<String, dynamic> json) {
    return AiChatGroupAttachment(
      id: _parseInt(json['id']) ?? _parseInt(json['groupId']) ?? 0,
      title: (json['title'] ?? json['groupTitle'] ?? 'Group').toString(),
      description: json['description']?.toString(),
    );
  }
}

class AiChatTeacherAttachment {
  const AiChatTeacherAttachment({
    required this.name,
    required this.email,
    this.groupId,
    this.groupTitle,
  });

  final String name;
  final String email;
  final int? groupId;
  final String? groupTitle;

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        if (groupId != null) 'groupId': groupId,
        if (groupTitle != null) 'groupTitle': groupTitle,
      };

  factory AiChatTeacherAttachment.fromJson(Map<String, dynamic> json) {
    return AiChatTeacherAttachment(
      name: (json['name'] ?? json['teacherName'] ?? 'Advisor').toString(),
      email: (json['email'] ?? json['teacherEmail'] ?? '').toString(),
      groupId: _parseInt(json['groupId']),
      groupTitle: json['groupTitle']?.toString(),
    );
  }
}

class AiChatMemberAttachment {
  const AiChatMemberAttachment({
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  final String name;
  final String email;
  final String? avatarUrl;

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };

  factory AiChatMemberAttachment.fromJson(Map<String, dynamic> json) {
    return AiChatMemberAttachment(
      name: (json['name'] ?? json['fullName'] ?? 'Member').toString(),
      email: (json['email'] ?? '').toString(),
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }
}

class AiChatGroupSummaryAttachment {
  const AiChatGroupSummaryAttachment({
    this.groupTitle,
    this.status,
    this.memberCount,
    this.memberLimit,
    this.majorCount,
    this.pendingRequests,
    this.extra = const {},
  });

  final String? groupTitle;
  final String? status;
  final int? memberCount;
  final int? memberLimit;
  final int? majorCount;
  final int? pendingRequests;
  final Map<String, dynamic> extra;

  bool get hasData =>
      groupTitle != null ||
      status != null ||
      memberCount != null ||
      memberLimit != null ||
      majorCount != null ||
      pendingRequests != null ||
      extra.isNotEmpty;

  Map<String, dynamic> toJson() => {
        if (groupTitle != null) 'groupTitle': groupTitle,
        if (status != null) 'status': status,
        if (memberCount != null) 'memberCount': memberCount,
        if (memberLimit != null) 'memberLimit': memberLimit,
        if (majorCount != null) 'majorCount': majorCount,
        if (pendingRequests != null) 'pendingRequests': pendingRequests,
        if (extra.isNotEmpty) 'extra': extra,
      };

  factory AiChatGroupSummaryAttachment.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AiChatGroupSummaryAttachment();

    Map<String, dynamic>? myGroup;
    if (json['myGroup'] is Map<String, dynamic>) {
      myGroup = Map<String, dynamic>.from(json['myGroup'] as Map);
    }

    int? parseIntFromAny(dynamic value) => _parseInt(value);

    return AiChatGroupSummaryAttachment(
      groupTitle: myGroup?['title']?.toString(),
      status: (myGroup?['status'] ?? json['status'])?.toString(),
      memberCount: parseIntFromAny(json['memberCount'] ?? myGroup?['memberCount']),
      memberLimit: parseIntFromAny(json['memberLimit'] ?? myGroup?['memberLimit']),
      majorCount: parseIntFromAny(json['majorCount']),
      pendingRequests: parseIntFromAny(json['pendingRequests']),
      extra: {
        if (myGroup != null) 'myGroup': myGroup,
        ...json,
      },
    );
  }
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}
