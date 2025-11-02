import 'package:booking_group_flutter/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef ChatMessageActionCallback = void Function(ChatMessage message);

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.selectionMode = false,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  final ChatMessage message;
  final bool isMine;
  final ChatMessageActionCallback? onReply;
  final ChatMessageActionCallback? onEdit;
  final ChatMessageActionCallback? onDelete;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  Color get _bubbleColor => isMine
      ? const Color(0xFF8B5CF6)
      : const Color(0xFFF1F5F9);

  Color get _textColor => isMine ? Colors.white : const Color(0xFF1F2937);

  Color get _selectionColor => isMine
      ? const Color(0xFF8B5CF6).withValues(alpha: 0.18)
      : const Color(0xFFCBD5F5).withValues(alpha: 0.3);

  BorderRadius get _borderRadius => BorderRadius.only(
        topLeft: const Radius.circular(18),
        topRight: const Radius.circular(18),
        bottomLeft: Radius.circular(isMine ? 18 : 6),
        bottomRight: Radius.circular(isMine ? 6 : 18),
      );

  @override
  Widget build(BuildContext context) {
    final timestamp = DateFormat('HH:mm').format(message.createdAt);
    final actions = <PopupMenuEntry<_MessageAction>>[
      PopupMenuItem(
        value: _MessageAction.reply,
        child: Row(
          children: const [
            Icon(Icons.reply, size: 18),
            SizedBox(width: 8),
            Text('Trả lời'),
          ],
        ),
      ),
      if (isMine)
        PopupMenuItem(
          value: _MessageAction.edit,
          child: Row(
            children: const [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Chỉnh sửa'),
            ],
          ),
        ),
      if (isMine)
        PopupMenuItem(
          value: _MessageAction.delete,
          child: Row(
            children: const [
              Icon(Icons.delete_outline, size: 18),
              SizedBox(width: 8),
              Text('Xóa'),
            ],
          ),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? _selectionColor : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMine)
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  child: Text(
                    _initials(message.senderName),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ),
              if (!isMine) const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment:
                      isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: isMine
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            message.senderName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isMine
                                  ? const Color.fromARGB(255, 230, 223, 255)
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        if (!selectionMode)
                          PopupMenuButton<_MessageAction>(
                            onSelected: (action) {
                              switch (action) {
                                case _MessageAction.reply:
                                  onReply?.call(message);
                                  break;
                                case _MessageAction.edit:
                                  onEdit?.call(message);
                                  break;
                                case _MessageAction.delete:
                                  onDelete?.call(message);
                                  break;
                              }
                            },
                            icon: Icon(
                              Icons.more_vert,
                              size: 18,
                              color: isMine
                                  ? const Color.fromARGB(255, 230, 223, 255)
                                  : Colors.black45,
                            ),
                            itemBuilder: (_) => actions,
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: isMine
                                ? Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    size: 18,
                                    color: isSelected
                                        ? const Color(0xFF8B5CF6)
                                        : const Color(0xFFCBD5F5),
                                  )
                                : const SizedBox(width: 18, height: 18),
                          ),
                      ],
                    ),
                if (message.hasReply && message.replyToContent != null)
                  Container(
                    margin: const EdgeInsets.only(top: 6, bottom: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMine
                          ? const Color.fromARGB(255, 108, 65, 193)
                              .withValues(alpha: 0.4)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFCBD5F5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      message.replyToContent!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isMine
                            ? const Color.fromARGB(255, 237, 235, 246)
                            : const Color(0xFF475569),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _bubbleColor,
                    borderRadius: _borderRadius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 15,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _buildMeta(timestamp),
                        style: TextStyle(
                          color: _textColor.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMine) const SizedBox(width: 8),
          if (isMine)
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              child: Text(
                _initials(message.senderName),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }

  String _buildMeta(String timestamp) {
    if (message.isEdited) {
      return '$timestamp • Đã chỉnh sửa';
    }
    return timestamp;
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final segments = trimmed.split(RegExp(r'\s+'));
    if (segments.length == 1) {
      return segments.first.characters.first.toUpperCase();
    }
    final first = segments.first.characters.first.toUpperCase();
    final last = segments.last.characters.first.toUpperCase();
    return '$first$last';
  }
}

enum _MessageAction { reply, edit, delete }
