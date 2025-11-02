import 'package:booking_group_flutter/features/chat/application/chat_controller.dart';
import 'package:booking_group_flutter/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:booking_group_flutter/models/chat_message.dart';
import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    super.key,
    required this.groupId,
    this.padding,
  });

  final int groupId;
  final EdgeInsetsGeometry? padding;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late final ChatController _controller;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  ChatMessage? _replyTo;
  ChatMessage? _editingMessage;
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = ChatController(groupId: widget.groupId);
    _controller.addListener(_handleControllerUpdate);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerUpdate);
    _controller.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _handleControllerUpdate() {
    final currentCount = _controller.messages.length;
    if (currentCount > _previousMessageCount && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
    _previousMessageCount = currentCount;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _scrollToBottom() async {
    if (!_scrollController.hasClients) return;
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _controller.isMutating) return;

    try {
      if (_editingMessage != null) {
        await _controller.updateMessage(_editingMessage!.id, text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã cập nhật tin nhắn.')),
          );
        }
      } else {
        await _controller.sendMessage(
          text,
          replyToMessageId: _replyTo?.id,
        );
      }

      if (!mounted) return;
      setState(() {
        _replyTo = null;
        _editingMessage = null;
        _textController.clear();
      });
      _inputFocusNode.requestFocus();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  void _handleReply(ChatMessage message) {
    setState(() {
      _replyTo = message;
      _editingMessage = null;
    });
    _inputFocusNode.requestFocus();
  }

  void _handleEdit(ChatMessage message) {
    setState(() {
      _editingMessage = message;
      _replyTo = null;
      _textController.text = message.content;
    });
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textController.text.length),
    );
    _inputFocusNode.requestFocus();
  }

  Future<void> _handleDelete(ChatMessage message) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tin nhắn'),
        content: const Text('Bạn có chắc chắn muốn xóa tin nhắn này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await _controller.deleteMessage(message.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa tin nhắn.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Widget _buildReplyPreview(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.reply, size: 18, color: Color(0xFF4C1D95)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trả lời ${message.senderName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF312E81),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF4C1D95)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              setState(() => _replyTo = null);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditingBanner(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF2F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDB2777).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit, size: 18, color: Color(0xFFDB2777)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Đang chỉnh sửa tin nhắn: "${message.content}"',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF9D174D)),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() => _editingMessage = null);
              _textController.clear();
            },
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = widget.padding ?? const EdgeInsets.all(16);
    final messages = _controller.messages;
    final isLoading = _controller.isLoading && messages.isEmpty;
    final errorMessage = _controller.errorMessage;
    final currentEmail = _controller.currentUserEmail;

    return Padding(
      padding: padding,
      child: Column(
        children: [
          if (errorMessage != null && messages.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFB91C1C)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Color(0xFFB91C1C)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _controller.refreshMessages(showLoading: true),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _controller.refreshMessages(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: messages.isEmpty ? 1 : messages.length,
                      itemBuilder: (context, index) {
                        if (messages.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 48),
                              child: Text(
                                'Chưa có tin nhắn nào. Hãy bắt đầu cuộc trò chuyện!',
                                style: TextStyle(color: Color(0xFF64748B)),
                              ),
                            ),
                          );
                        }

                        final message = messages[index];
                        final senderEmail = message.senderEmail?.toLowerCase();
                        final isMine = currentEmail != null &&
                            senderEmail != null &&
                            senderEmail == currentEmail;
                        return ChatMessageBubble(
                          message: message,
                          isMine: isMine,
                          onReply: _handleReply,
                          onEdit: isMine ? _handleEdit : null,
                          onDelete: isMine ? _handleDelete : null,
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          if (_replyTo != null) _buildReplyPreview(_replyTo!),
          if (_editingMessage != null) _buildEditingBanner(_editingMessage!),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final isBusy = _controller.isMutating;

    return SafeArea(
      top: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _inputFocusNode,
              textInputAction: TextInputAction.newline,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: _editingMessage != null
                    ? 'Chỉnh sửa tin nhắn...'
                    : 'Nhập tin nhắn...',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 12),
          DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0xFF8B5CF6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: isBusy ? null : _handleSend,
              icon: isBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
