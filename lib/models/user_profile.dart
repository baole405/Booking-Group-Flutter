import 'package:booking_group_flutter/models/major.dart';

class UserProfile {
  final String? studentCode;
  final String fullName;
  final String email;
  final String? cwu;
  final String? avatarUrl;
  final Major? major;
  final String role;
  final bool isActive;

  UserProfile({
    this.studentCode,
    required this.fullName,
    required this.email,
    this.cwu,
    this.avatarUrl,
    this.major,
    required this.role,
    this.isActive = true,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      studentCode: json['studentCode'] as String?,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      cwu: json['cwu'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      major: json['major'] != null ? Major.fromJson(json['major']) : null,
      role: json['role'] as String? ?? 'STUDENT',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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

  // Helper để lấy tên hiển thị
  String get displayName {
    if (fullName.isNotEmpty) return fullName;
    // Nếu không có fullName, lấy từ email
    return email.split('@').first;
  }

  // Helper để hiển thị student code hoặc email
  String get identifier {
    if (studentCode != null && studentCode!.isNotEmpty) {
      return studentCode!;
    }
    return 'Không rõ mã số';
  }
}
