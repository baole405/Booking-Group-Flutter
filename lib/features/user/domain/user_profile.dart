class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.role,
    this.studentCode,
    this.majorName,
    this.avatarUrl,
    this.group,
  });

  final int id;
  final String email;
  final String? fullName;
  final String? role;
  final String? studentCode;
  final String? majorName;
  final String? avatarUrl;
  final GroupRef? group;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final majorJson = json['majorResponse'] ?? json['major'];
    final groupJson = json['groupResponse'] ?? json['group'] ?? json['groupInfo'];

    return UserProfile(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ??
          json['name'] as String? ??
          json['displayName'] as String?,
      role: json['role'] as String? ?? json['userRole'] as String?,
      studentCode: json['studentCode'] as String?,
      majorName: _parseMajorName(majorJson),
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar'] as String?,
      group: groupJson is Map<String, dynamic>
          ? GroupRef.fromJson(groupJson)
          : null,
    );
  }

  static String? _parseMajorName(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return raw;
    if (raw is Map<String, dynamic>) {
      return raw['name'] as String? ??
          raw['majorName'] as String? ??
          raw['code'] as String?;
    }
    return null;
  }
}

class GroupRef {
  const GroupRef({
    required this.id,
    required this.title,
    this.status,
    this.type,
  });

  final int id;
  final String title;
  final String? status;
  final String? type;

  factory GroupRef.fromJson(Map<String, dynamic> json) {
    return GroupRef(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? json['name'] as String? ?? 'Group',
      status: json['status'] as String?,
      type: json['type'] as String?,
    );
  }
}
