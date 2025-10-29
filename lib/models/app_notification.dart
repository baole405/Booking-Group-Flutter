class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    this.createdAt,
  });

  final int id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  bool get isUnread => !isRead;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final id = _parseId(json);
    final title = _parseTitle(json);
    final message = _parseMessage(json);
    final createdAt = _parseDate(json['createdAt'] ?? json['created_at']);
    final isRead = _parseReadStatus(json);

    return AppNotification(
      id: id,
      title: title,
      message: message,
      isRead: isRead,
      createdAt: createdAt,
    );
  }

  AppNotification copyWith({
    int? id,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  int get hashCode => Object.hash(id, title, message, isRead, createdAt);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is AppNotification &&
        other.id == id &&
        other.title == title &&
        other.message == message &&
        other.isRead == isRead &&
        other.createdAt == createdAt;
  }
}

int _parseId(Map<String, dynamic> json) {
  final rawId = json['id'] ?? json['notificationId'] ?? json['notification_id'];
  if (rawId is int) return rawId;
  if (rawId is num) return rawId.toInt();
  if (rawId is String) {
    return int.tryParse(rawId) ?? rawId.hashCode;
  }
  return DateTime.now().millisecondsSinceEpoch;
}

String _parseTitle(Map<String, dynamic> json) {
  final candidates = [
    json['title'],
    json['subject'],
    json['type'],
  ];

  for (final candidate in candidates) {
    if (candidate is String && candidate.trim().isNotEmpty) {
      return candidate.trim();
    }
  }

  return 'Notification';
}

String _parseMessage(Map<String, dynamic> json) {
  final candidates = [
    json['message'],
    json['content'],
    json['body'],
    json['description'],
  ];

  for (final candidate in candidates) {
    if (candidate is String && candidate.trim().isNotEmpty) {
      return candidate.trim();
    }
  }

  return '';
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is String && value.isNotEmpty) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
  return null;
}

bool _parseReadStatus(Map<String, dynamic> json) {
  final rawIsRead = json['isRead'] ?? json['read'] ?? json['seen'];
  if (rawIsRead is bool) {
    return rawIsRead;
  }
  if (rawIsRead is num) {
    return rawIsRead != 0;
  }
  if (rawIsRead is String) {
    final normalized = rawIsRead.toLowerCase();
    if (normalized == 'true' || normalized == 'read' || normalized == 'seen') {
      return true;
    }
    if (normalized == 'false' || normalized == 'unread') {
      return false;
    }
  }

  final status = json['status'];
  if (status is String) {
    final normalized = status.toUpperCase();
    if (normalized == 'UNREAD' || normalized == 'NEW') {
      return false;
    }
    if (normalized == 'READ' || normalized == 'DONE') {
      return true;
    }
  }
  if (status is num) {
    // Some backends encode unread notifications with 200/201 codes.
    if (status == 200 || status == 201) {
      return false;
    }
    if (status == 204 || status == 205) {
      return true;
    }
  }

  final readAt = json['readAt'] ?? json['read_at'];
  if (readAt != null) {
    return true;
  }

  return false;
}
