class JoinRequest {
  final int id;
  final int userId;
  final int groupId;
  final String status;
  final String createdAt;
  final GroupInfo? group;

  JoinRequest({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.status,
    required this.createdAt,
    this.group,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? groupJson =
        json['group'] is Map ? Map<String, dynamic>.from(json['group']) : null;

    return JoinRequest(
      id: _parseInt(json['id']),
      userId: _parseInt(json['userId']),
      groupId: _deriveGroupId(json, groupJson),
      status: (json['status'] as String?) ?? '',
      createdAt: (json['createdAt'] as String?) ?? '',
      group: groupJson != null ? GroupInfo.fromJson(groupJson) : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int _deriveGroupId(
    Map<String, dynamic> json,
    Map<String, dynamic>? groupJson,
  ) {
    final dynamic directValue = json['groupId'] ?? json['groupID'];
    if (directValue != null) {
      final parsed = _parseInt(directValue);
      if (parsed != 0) return parsed;
    }

    if (groupJson != null) {
      final parsed = _parseInt(
        groupJson['id'] ?? groupJson['groupId'] ?? groupJson['groupID'],
      );
      if (parsed != 0) return parsed;
    }

    return 0;
  }
}

class GroupInfo {
  final int id;
  final String title;
  final String status;
  final String type;

  GroupInfo({
    required this.id,
    required this.title,
    required this.status,
    required this.type,
  });

  factory GroupInfo.fromJson(Map<String, dynamic> json) {
    final int id = JoinRequest._parseInt(
      json['id'] ?? json['groupId'] ?? json['groupID'],
    );

    final String? detectedTitle = _detectTitle(json);
    final String? detectedStatus =
        json['status'] ?? json['groupStatus'] ?? json['statusName'];
    final String? detectedType =
        json['type'] ?? json['groupType'] ?? json['typeName'];

    return GroupInfo(
      id: id,
      title: detectedTitle ?? 'Nhóm không tên',
      status: detectedStatus is String ? detectedStatus : '',
      type: detectedType is String ? detectedType : '',
    );
  }

  static String? _detectTitle(Map<String, dynamic> json) {
    const possibleKeys = ['title', 'name', 'groupName', 'groupTitle'];
    for (final key in possibleKeys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}
