import 'package:booking_group_flutter/models/post.dart';

enum InviteStatus { pending, accepted, declined }

extension InviteStatusMapper on InviteStatus {
  String get backendValue {
    switch (this) {
      case InviteStatus.pending:
        return 'PENDING';
      case InviteStatus.accepted:
        return 'ACCEPTED';
      case InviteStatus.declined:
        return 'DECLINED';
    }
  }

  static InviteStatus fromBackend(String? value) {
    switch (value?.toUpperCase()) {
      case 'ACCEPTED':
        return InviteStatus.accepted;
      case 'DECLINED':
        return InviteStatus.declined;
      case 'PENDING':
      default:
        return InviteStatus.pending;
    }
  }
}

class Invite {
  final int id;
  final GroupResponse group;
  final UserResponse inviter;
  final UserResponse invitee;
  final InviteStatus status;
  final DateTime? createdAt;
  final DateTime? respondedAt;

  Invite({
    required this.id,
    required this.group,
    required this.inviter,
    required this.invitee,
    required this.status,
    required this.createdAt,
    required this.respondedAt,
  });

  factory Invite.fromJson(Map<String, dynamic> json) {
    return Invite(
      id: json['id'] as int? ?? 0,
      group: GroupResponse.fromJson(
        json['group'] as Map<String, dynamic>? ?? {},
      ),
      inviter: UserResponse.fromJson(
        json['inviter'] as Map<String, dynamic>? ?? {},
      ),
      invitee: UserResponse.fromJson(
        json['invitee'] as Map<String, dynamic>? ?? {},
      ),
      status: InviteStatusMapper.fromBackend(json['status'] as String?),
      createdAt: _parseDate(json['createdAt'] as String?),
      respondedAt: _parseDate(json['respondedAt'] as String?),
    );
  }

  static DateTime? _parseDate(String? value) {
    if (value == null) {
      return null;
    }

    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
}

class PaginatedInvites {
  final List<Invite> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;

  const PaginatedInvites({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory PaginatedInvites.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PaginatedInvites(
        content: [],
        page: 1,
        size: 0,
        totalElements: 0,
        totalPages: 0,
        last: true,
      );
    }

    return PaginatedInvites(
      content: (json['content'] as List<dynamic>? ?? [])
          .map((item) => Invite.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 1,
      size: json['size'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      last: json['last'] as bool? ?? true,
    );
  }
}

class MyInvites {
  final PaginatedInvites received;
  final PaginatedInvites sent;

  const MyInvites({
    required this.received,
    required this.sent,
  });

  factory MyInvites.fromJson(Map<String, dynamic> json) {
    return MyInvites(
      received: PaginatedInvites.fromJson(
        json['received'] as Map<String, dynamic>?,
      ),
      sent: PaginatedInvites.fromJson(
        json['sent'] as Map<String, dynamic>?,
      ),
    );
  }
}
