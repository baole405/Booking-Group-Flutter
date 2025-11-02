import 'package:flutter/foundation.dart';

/// Supported message types for the group chat experience.
enum ChatMessageType { text, image, file }

ChatMessageType _chatMessageTypeFromString(String? value) {
  switch (value?.toUpperCase()) {
    case 'IMAGE':
      return ChatMessageType.image;
    case 'FILE':
      return ChatMessageType.file;
    case 'TEXT':
    default:
      return ChatMessageType.text;
  }
}

String chatMessageTypeToString(ChatMessageType type) {
  switch (type) {
    case ChatMessageType.image:
      return 'IMAGE';
    case ChatMessageType.file:
      return 'FILE';
    case ChatMessageType.text:
      return 'TEXT';
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

/// Representation of a single message in a group chat.
@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    this.senderEmail,
    required this.content,
    required this.messageType,
    required this.createdAt,
    this.updatedAt,
    this.isEdited = false,
    this.replyToMessageId,
    this.replyToContent,
  });

  final int id;
  final int groupId;
  final int senderId;
  final String senderName;
  final String? senderEmail;
  final String content;
  final ChatMessageType messageType;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEdited;
  final int? replyToMessageId;
  final String? replyToContent;

  bool get hasReply => replyToMessageId != null && replyToMessageId! > 0;

  bool get hasContent => content.trim().isNotEmpty;

  ChatMessage copyWith({
    int? id,
    int? groupId,
    int? senderId,
    String? senderName,
    String? senderEmail,
    String? content,
    ChatMessageType? messageType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEdited,
    int? replyToMessageId,
    String? replyToContent,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderEmail: senderEmail ?? this.senderEmail,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToContent: replyToContent ?? this.replyToContent,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        try {
          return DateTime.parse(value).toLocal();
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    int? resolveReplyId() {
      final direct = _parseInt(json['replyToMessageId']);
      if (direct != null && direct > 0) {
        return direct;
      }

      final reply = json['reply'];
      if (reply is Map<String, dynamic>) {
        final nestedId = _parseInt(reply['replyToMessageId']) ??
            _parseInt(reply['id']) ??
            _parseInt(reply['messageId']);
        if (nestedId != null && nestedId > 0) {
          return nestedId;
        }
      }

      return null;
    }

    String? resolveReplyContent() {
      final direct = json['replyToContent'];
      if (direct is String && direct.isNotEmpty) {
        return direct;
      }

      final reply = json['reply'];
      if (reply is Map<String, dynamic>) {
        final nested = reply['replyToContent'];
        if (nested is String && nested.isNotEmpty) {
          return nested;
        }

        final content = reply['content'];
        if (content is String && content.isNotEmpty) {
          return content;
        }
      }

      return null;
    }

    return ChatMessage(
      id: _parseInt(json['id']) ?? 0,
      groupId: _parseInt(json['groupId']) ?? 0,
      senderId: _parseInt(json['fromUserId']) ??
          _parseInt(json['senderId']) ??
          0,
      senderName: (json['fromUserName'] as String?) ??
          (json['senderName'] as String?) ??
          'Unknown',
      senderEmail: (json['fromUserEmail'] as String?) ??
          (json['senderEmail'] as String?),
      content: (json['content'] as String?) ?? json['message'] as String? ?? '',
      messageType: _chatMessageTypeFromString(
        json['messageType'] as String? ?? json['type'] as String?,
      ),
      createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDate(json['updatedAt']),
      isEdited: json['isEdited'] == true || json['edited'] == true,
      replyToMessageId: resolveReplyId(),
      replyToContent: resolveReplyContent(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': groupId,
        'fromUserId': senderId,
        'fromUserName': senderName,
        if (senderEmail != null) 'fromUserEmail': senderEmail,
        'content': content,
        'messageType': chatMessageTypeToString(messageType),
        'createdAt': createdAt.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
        'isEdited': isEdited,
        if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
        if (replyToContent != null) 'replyToContent': replyToContent,
      };
}
