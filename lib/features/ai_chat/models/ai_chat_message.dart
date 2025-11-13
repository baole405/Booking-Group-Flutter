import 'package:booking_group_flutter/features/ai_chat/models/ai_chat_attachments.dart';

enum AiChatRole { user, assistant, system }

AiChatRole roleFromString(String? value) {
  switch (value?.toUpperCase()) {
    case 'USER':
      return AiChatRole.user;
    case 'ASSISTANT':
      return AiChatRole.assistant;
    case 'SYSTEM':
      return AiChatRole.system;
    default:
      return AiChatRole.assistant;
  }
}

String roleToString(AiChatRole role) {
  switch (role) {
    case AiChatRole.user:
      return 'USER';
    case AiChatRole.assistant:
      return 'ASSISTANT';
    case AiChatRole.system:
      return 'SYSTEM';
  }
}

class AiChatMessage {
  AiChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.attachments = const AiChatAttachmentBundle(),
    this.isPending = false,
    this.isError = false,
    this.errorMessage,
    this.isLocalOnly = false,
  });

  final String id;
  final AiChatRole role;
  final String content;
  final DateTime createdAt;
  final AiChatAttachmentBundle attachments;
  final bool isPending;
  final bool isError;
  final String? errorMessage;
  final bool isLocalOnly;

  bool get hasAttachments => attachments.hasContent;

  AiChatMessage copyWith({
    String? id,
    AiChatRole? role,
    String? content,
    DateTime? createdAt,
    AiChatAttachmentBundle? attachments,
    bool? isPending,
    bool? isError,
    String? errorMessage,
    bool? isLocalOnly,
  }) {
    return AiChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      attachments: attachments ?? this.attachments,
      isPending: isPending ?? this.isPending,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      isLocalOnly: isLocalOnly ?? this.isLocalOnly,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': roleToString(role),
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'attachments': attachments.toJson(),
        'isPending': isPending,
        'isError': isError,
        if (errorMessage != null) 'errorMessage': errorMessage,
        'isLocalOnly': isLocalOnly,
      };

  factory AiChatMessage.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        try {
          return DateTime.parse(value).toLocal();
        } catch (_) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    String resolveId() {
      final source = (json['id'] ?? json['messageId'] ?? json['uuid'] ?? '')
          .toString()
          .trim();
      if (source.isNotEmpty) return source;
      return 'msg-${DateTime.now().millisecondsSinceEpoch}';
    }

    AiChatAttachmentBundle resolveAttachments() {
      final attachmentSource = json['attachments'] ?? json['attachment'];
      if (attachmentSource != null) {
        return AiChatAttachmentBundle.fromJson(attachmentSource);
      }
      return const AiChatAttachmentBundle();
    }

    return AiChatMessage(
      id: resolveId(),
      role: roleFromString(json['role']?.toString()),
      content:
          (json['content'] ?? json['message'] ?? json['answer'] ?? '').toString(),
      createdAt: parseDate(json['createdAt']),
      attachments: resolveAttachments(),
      isPending: json['isPending'] == true,
      isError: json['isError'] == true,
      errorMessage: json['errorMessage']?.toString(),
      isLocalOnly: json['isLocalOnly'] == true,
    );
  }

  static AiChatMessage placeholderAssistant() {
    return AiChatMessage(
      id: 'assistant-placeholder-${DateTime.now().millisecondsSinceEpoch}',
      role: AiChatRole.assistant,
      content: 'Waiting...',
      createdAt: DateTime.now(),
      attachments: const AiChatAttachmentBundle(),
      isPending: true,
    );
  }
}
