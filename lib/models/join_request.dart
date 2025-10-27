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
    return JoinRequest(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      groupId: json['groupId'] ?? 0,
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      group: json['group'] != null ? GroupInfo.fromJson(json['group']) : null,
    );
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
    return GroupInfo(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      type: json['type'] ?? '',
    );
  }
}
