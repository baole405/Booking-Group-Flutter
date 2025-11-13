import 'package:booking_group_flutter/features/ai_chat/application/ai_chat_controller.dart';
import 'package:booking_group_flutter/features/ai_chat/models/ai_chat_attachments.dart';
import 'package:booking_group_flutter/features/ai_chat/presentation/widgets/ai_chat_message_bubble.dart';
import 'package:booking_group_flutter/features/groups/presentation/pages/group_detail_page.dart';
import 'package:flutter/material.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  late final AiChatController _controller;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AiChatController();
    _controller.addListener(_handleControllerUpdate);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerUpdate);
    _controller.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleControllerUpdate() {
    final currentCount = _controller.messages.length;
    if (currentCount > _previousMessageCount) {
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
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    await _controller.sendMessage(text);
    _inputController.clear();
  }

  void _openGroup(int groupId, {String? title}) {
    if (!mounted || groupId <= 0) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GroupDetailPage(
          groupId: groupId,
          groupTitle: title ?? 'Group #$groupId',
        ),
      ),
    );
  }

  void _handleTeacherTap(AiChatTeacherAttachment teacher) {
    if (teacher.groupId != null && teacher.groupId! > 0) {
      _openGroup(teacher.groupId!, title: teacher.groupTitle);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Liên hệ ${teacher.email} để trao đổi chi tiết.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _controller.isSending;
    final hasError = _controller.errorMessage != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (hasError)
            MaterialBanner(
              content: Text(
                _controller.errorMessage ?? 'Không thể tải chatbot.',
              ),
              leading: const Icon(Icons.warning_amber_rounded),
              backgroundColor: Colors.orange.shade50,
              actions: [
                TextButton(
                  onPressed: _controller.refreshHistory,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          Expanded(child: _buildConversation()),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Hãy hỏi điều gì đó...',
                      filled: true,
                      fillColor: Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: isBusy ? null : _handleSend,
                    icon: isBusy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversation() {
    final messages = _controller.messages;

    if (_controller.isLoading && messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messages.isEmpty) {
      return RefreshIndicator(
        onRefresh: _controller.refreshHistory,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Icon(Icons.smart_toy_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Bắt đầu cuộc trò chuyện với trợ lý AI để nhận gợi ý về nhóm.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _controller.refreshHistory,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return AiChatMessageBubble(
            message: message,
            onRetry: message.isError ? _controller.retryLast : null,
            onGroupTap: (groupId, {title}) => _openGroup(groupId, title: title),
            onTeacherTap: _handleTeacherTap,
          );
        },
      ),
    );
  }
}
