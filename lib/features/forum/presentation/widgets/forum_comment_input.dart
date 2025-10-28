import 'package:flutter/material.dart';

class ForumCommentInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final VoidCallback onSend;

  const ForumCommentInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Viết bình luận...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: isSending ? null : onSend,
            icon: isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            color: const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }
}
