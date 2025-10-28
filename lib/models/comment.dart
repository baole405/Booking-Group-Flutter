import 'package:booking_group_flutter/models/post.dart';

class Comment {
  final int id;
  final int postId;
  final UserResponse userResponse;
  final String content;
  final String createdAt;
  final bool active;

  Comment({
    required this.id,
    required this.postId,
    required this.userResponse,
    required this.content,
    required this.createdAt,
    required this.active,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final postJson = json['post'] as Map<String, dynamic>?;
    final userJson = (json['userResponse'] ?? json['user']) as Map<String, dynamic>?;

    return Comment(
      id: json['id'] as int? ?? 0,
      postId: json['postId'] as int? ?? postJson?['id'] as int? ?? 0,
      userResponse: UserResponse.fromJson(userJson ?? {}),
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      active: json['active'] as bool? ?? true,
    );
  }
}
