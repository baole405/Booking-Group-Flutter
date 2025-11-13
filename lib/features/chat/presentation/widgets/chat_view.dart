import 'dart:async';

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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  ChatMessage? _replyTo;
  ChatMessage? _editingMessage;
  int _previousMessageCount = 0;
  List<ChatMessage> _searchResults = const [];
  Timer? _searchDebounce;
  bool _isSearchVisible = false;
  bool _isSearching = false;
  String _searchKeyword = '';
  final Set<int> _selectedMessageIds = <int>{};

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
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _handleControllerUpdate() {
    final currentCount = _controller.messages.length;
    if (currentCount > _previousMessageCount && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
    _previousMessageCount = currentCount;

    if (_selectedMessageIds.isNotEmpty) {
      final availableIds = {
        ..._controller.messages.map((message) => message.id),
        ..._searchResults.map((message) => message.id),
      };
      final removed =
          _selectedMessageIds.difference(availableIds).isNotEmpty;
      _selectedMessageIds.removeWhere((id) => !availableIds.contains(id));
      if (removed && _selectedMessageIds.isEmpty) {
        // Do not call _clearSelection() here to avoid nested setState.
        _selectedMessageIds.clear();
      }
    }

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
        _selectedMessageIds.clear();
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
      _selectedMessageIds.clear();
    });
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textController.text.length),
    );
    _inputFocusNode.requestFocus();
  }

  void _toggleSearch() {
    setState(() {
      if (_isSearchVisible) {
        _clearSearchState();
        _isSearchVisible = false;
      } else {
        _isSearchVisible = true;
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _clearSearchState() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _searchResults = const [];
    _searchKeyword = '';
    _isSearching = false;
  }

  void _clearSelection() {
    if (_selectedMessageIds.isEmpty) return;
    setState(() {
      _selectedMessageIds.clear();
    });
  }

  void _onSearchChanged(String value) {
    final keyword = value.trim();
    setState(() {
      _searchKeyword = keyword;
    });

    _searchDebounce?.cancel();
    if (keyword.length < 2) {
      setState(() {
        _searchResults = const [];
        _isSearching = false;
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _performSearch(keyword);
    });
  }

  Future<void> _performSearch(String keyword) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _controller.searchMessages(keyword);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
      });
    }
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
      _selectedMessageIds.remove(message.id);
      setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  void _toggleSelection(ChatMessage message, bool isMine) {
    if (!isMine) {
      return;
    }

    setState(() {
      if (_selectedMessageIds.contains(message.id)) {
        _selectedMessageIds.remove(message.id);
      } else {
        _selectedMessageIds.add(message.id);
      }
    });
  }

  ChatMessage? _findMessageById(int id) {
    for (final message in _controller.messages) {
      if (message.id == id) return message;
    }
    for (final message in _searchResults) {
      if (message.id == id) return message;
    }
    return null;
  }

  Future<void> _startEditingSelectedMessage() async {
    if (_selectedMessageIds.length != 1) return;
    final id = _selectedMessageIds.first;
    final message = _findMessageById(id);
    if (message == null) {
      _clearSelection();
      return;
    }
    _handleEdit(message);
  }

  Future<void> _handleBulkDeleteSelection() async {
    if (_selectedMessageIds.isEmpty) return;
    final ids = _selectedMessageIds.toList();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tin nhắn đã chọn'),
        content: Text(
          ids.length == 1
              ? 'Bạn có chắc chắn muốn xóa tin nhắn này?'
              : 'Bạn có chắc chắn muốn xóa ${ids.length} tin nhắn đã chọn?',
        ),
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
      for (final id in ids) {
        await _controller.deleteMessage(id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ids.length == 1
              ? 'Đã xóa tin nhắn.'
              : 'Đã xóa ${ids.length} tin nhắn.'),
        ),
      );
      _clearSelection();
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
    final currentUserId = _controller.currentUserId;
    final isSearchActive =
        _isSearchVisible && _searchKeyword.trim().length >= 2;
    final displayMessages =
        isSearchActive ? _searchResults : messages;
    final isDisplayingEmptySearch =
        isSearchActive && !_isSearching && displayMessages.isEmpty;
    final isSelectionMode = _selectedMessageIds.isNotEmpty;

    return Padding(
      padding: padding,
      child: Column(
        children: [
          _buildToolbar(),
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
                      itemCount:
                          displayMessages.isEmpty ? 1 : displayMessages.length,
                      itemBuilder: (context, index) {
                        if (displayMessages.isEmpty) {
                          if (isSearchActive && _isSearching) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 48),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final label = isSearchActive
                              ? 'Không tìm thấy tin nhắn phù hợp.'
                              : 'Chưa có tin nhắn nào. Hãy bắt đầu cuộc trò chuyện!';
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 48),
                              child: Text(
                                label,
                                style: const TextStyle(color: Color(0xFF64748B)),
                              ),
                            ),
                          );
                        }

                        final message = displayMessages[index];
                        final senderEmail =
                            message.senderEmail?.trim().toLowerCase();
                        final isMine = (currentEmail != null &&
                                senderEmail != null &&
                                senderEmail == currentEmail) ||
                            (currentUserId != null &&
                                currentUserId > 0 &&
                                message.senderId == currentUserId);
                        final isSelected =
                            _selectedMessageIds.contains(message.id);
                        return ChatMessageBubble(
                          message: message,
                          isMine: isMine,
                          selectionMode: isSelectionMode,
                          isSelected: isSelected,
                          onTap: isSelectionMode
                              ? () => _toggleSelection(message, isMine)
                              : null,
                          onLongPress:
                              isMine ? () => _toggleSelection(message, isMine) : null,
                          onReply:
                              isSelectionMode ? null : _handleReply,
                          onEdit:
                              isMine && !isSelectionMode ? _handleEdit : null,
                          onDelete: isMine && !isSelectionMode
                              ? _handleDelete
                              : null,
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          if (isSearchActive)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _isSearching
                      ? 'Đang tìm kiếm tin nhắn...'
                      : isDisplayingEmptySearch
                          ? 'Không có kết quả cho "$_searchKeyword".'
                          : 'Đang hiển thị kết quả tìm kiếm cho "$_searchKeyword".',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          if (_replyTo != null) _buildReplyPreview(_replyTo!),
          if (_editingMessage != null) _buildEditingBanner(_editingMessage!),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    if (_selectedMessageIds.isNotEmpty) {
      return _buildSelectionToolbar();
    }

    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (child, animation) => ClipRect(
                  child: SizeTransition(
                    sizeFactor: animation,
                    axis: Axis.horizontal,
                    axisAlignment: -1.0,
                    child: child,
                  ),
                ),
                child: _isSearchVisible
                    ? Container(
                        key: const ValueKey('search-field'),
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: 'Tìm tin nhắn (≥ 2 ký tự)...',
                                ),
                                onChanged: _onSearchChanged,
                                onSubmitted: (value) =>
                                    _performSearch(value.trim()),
                              ),
                            ),
                            if (_searchKeyword.isNotEmpty)
                              IconButton(
                                tooltip: 'Xóa tìm kiếm',
                                onPressed: () {
                                  setState(() {
                                    _clearSearchState();
                                  });
                                  _searchFocusNode.requestFocus();
                                },
                                icon: const Icon(Icons.close, size: 18),
                              ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('search-placeholder'),
                      ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: _toggleSearch,
              icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
              label: Text(_isSearchVisible ? 'Đóng' : 'Tìm kiếm'),
            ),
          ],
        ),
        if (_isSearchVisible)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Nhập từ khóa để tìm trong lịch sử hội thoại.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSelectionToolbar() {
    final count = _selectedMessageIds.length;
    final canEdit = count == 1 && !_controller.isMutating;
    final canDelete = !_controller.isMutating && count > 0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Hủy chọn',
                onPressed: _controller.isMutating ? null : _clearSelection,
                icon: const Icon(Icons.close),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  count == 1
                      ? 'Đang chọn 1 tin nhắn'
                      : 'Đang chọn $count tin nhắn',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              if (canEdit)
                IconButton(
                  tooltip: 'Chỉnh sửa tin nhắn',
                  onPressed: _startEditingSelectedMessage,
                  icon: const Icon(Icons.edit),
                ),
              IconButton(
                tooltip: 'Xóa tin nhắn đã chọn',
                onPressed:
                    canDelete ? _handleBulkDeleteSelection : null,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
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
