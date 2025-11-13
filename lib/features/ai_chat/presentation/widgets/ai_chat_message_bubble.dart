import 'package:booking_group_flutter/features/ai_chat/models/ai_chat_message.dart';
import 'package:booking_group_flutter/features/ai_chat/presentation/widgets/ai_chat_attachments_view.dart';
import 'package:flutter/material.dart';

class AiChatMessageBubble extends StatelessWidget {
  const AiChatMessageBubble({
    super.key,
    required this.message,
    this.onRetry,
    this.onGroupTap,
    this.onTeacherTap,
  });

  final AiChatMessage message;
  final VoidCallback? onRetry;
  final GroupTapCallback? onGroupTap;
  final TeacherTapCallback? onTeacherTap;

  bool get isMine => message.role == AiChatRole.user;

  @override
  Widget build(BuildContext context) {
    final bubbleColor =
        isMine ? const Color(0xFF8B5CF6) : const Color(0xFFF8FAFC);
    final textColor = isMine ? Colors.white : const Color(0xFF1F2937);
    final displayContent = message.content.isNotEmpty
        ? message.content
        : (message.isPending ? 'Đang gửi...' : '');
    final showTextBlock = displayContent.isNotEmpty;

    final bubble = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMine ? 20 : 6),
            bottomRight: Radius.circular(isMine ? 6 : 20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (showTextBlock) ...[
                Text(
                  displayContent,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment:
                    isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Text(
                    _formatTimestamp(message.createdAt),
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                  if (message.isPending) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    ),
                  ],
                ],
              ),
              if (message.isError) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.errorMessage ??
                            'Không thể gửi yêu cầu tới chatbot.',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Thử gửi lại'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
            child: bubble,
          ),
          if (message.hasAttachments)
            Align(
              alignment: Alignment.centerLeft,
              child: AiChatAttachmentsView(
                attachments: message.attachments,
                onGroupTap: onGroupTap,
                onTeacherTap: onTeacherTap,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final hours = timestamp.hour.toString().padLeft(2, '0');
    final minutes = timestamp.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
