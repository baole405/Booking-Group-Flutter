import 'package:booking_group_flutter/models/major.dart';

/// Group Member model
class GroupMember {
  final int id;
  final String? studentCode;
  final String fullName;
  final String email;
  final String? cwu;
  final String? avatarUrl;
  final Major? major;
  final String role;
  final bool isActive;

  GroupMember({
    required this.id,
    this.studentCode,
    required this.fullName,
    required this.email,
    this.cwu,
    this.avatarUrl,
    this.major,
    required this.role,
    required this.isActive,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] as int,
      studentCode: json['studentCode'] as String?,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      cwu: json['cwu'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      major: json['major'] != null ? Major.fromJson(json['major']) : null,
      role: json['role'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentCode': studentCode,
      'fullName': fullName,
      'email': email,
      'cwu': cwu,
      'avatarUrl': avatarUrl,
      'major': major?.toJson(),
      'role': role,
      'isActive': isActive,
    };
  }

  String get displayName => fullName;
  String get identifier => studentCode ?? email;
}
