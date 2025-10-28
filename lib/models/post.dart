class Post {
  final int id;
  final UserResponse userResponse;
  final GroupResponse? groupResponse;
  final String content;
  final String type;
  final String createdAt;
  final bool active;

  Post({
    required this.id,
    required this.userResponse,
    this.groupResponse,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.active,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      userResponse: UserResponse.fromJson(json['userResponse'] ?? {}),
      groupResponse: json['groupResponse'] != null
          ? GroupResponse.fromJson(json['groupResponse'])
          : null,
      content: json['content'] ?? '',
      type: json['type'] ?? '',
      createdAt: json['createdAt'] ?? '',
      active: json['active'] ?? false,
    );
  }
}

class UserResponse {
  final int id;
  final String studentCode;
  final String fullName;
  final String email;
  final String? prefix;
  final String? avatarUrl;
  final String? major;
  final String role;
  final bool isActive;

  UserResponse({
    required this.id,
    required this.studentCode,
    required this.fullName,
    required this.email,
    this.prefix,
    this.avatarUrl,
    this.major,
    required this.role,
    required this.isActive,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] ?? 0,
      studentCode: json['studentCode'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      prefix: _stringOrNull(json['prefix']),
      avatarUrl: _extractAvatarUrl(json['avatarUrl']),
      major: _extractMajor(json['major']),
      role: json['role'] ?? 'STUDENT',
      isActive: json['isActive'] ?? true,
    );
  }

  String get displayName {
    if (fullName.isNotEmpty) {
      return fullName;
    }
    if (email.isNotEmpty) {
      return email;
    }
    return 'Ẩn danh';
  }

  String get safeEmail {
    if (email.isNotEmpty) {
      return email;
    }
    return 'Chưa cung cấp email';
  }

  String get avatarInitial {
    final trimmed = displayName.trim();
    if (trimmed.isNotEmpty) {
      return trimmed.substring(0, 1).toUpperCase();
    }
    return '?';
  }

  static String? _extractMajor(dynamic major) {
    if (major == null) {
      return null;
    }

    if (major is String) {
      return major;
    }

    if (major is Map<String, dynamic>) {
      final name = major['name'];
      if (name is String && name.isNotEmpty) {
        return name;
      }
    }

    return null;
  }

  static String? _extractAvatarUrl(dynamic avatar) {
    if (avatar == null) {
      return null;
    }

    if (avatar is String && avatar.isNotEmpty) {
      return avatar;
    }

    if (avatar is Map<String, dynamic>) {
      final candidates = [
        avatar['url'],
        avatar['signedUrl'],
        avatar['path'],
        avatar['value'],
      ];

      for (final candidate in candidates) {
        if (candidate is String && candidate.isNotEmpty) {
          return candidate;
        }
      }
    }

    return null;
  }

  static String? _stringOrNull(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }
}

class GroupResponse {
  final int id;
  final String title;

  GroupResponse({required this.id, required this.title});

  factory GroupResponse.fromJson(Map<String, dynamic> json) {
    return GroupResponse(id: json['id'] ?? 0, title: json['title'] ?? '');
  }
}
