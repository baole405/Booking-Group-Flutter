import 'package:booking_group_flutter/features/ai_chat/models/ai_chat_message.dart';
import 'package:booking_group_flutter/resources/ai_chat_api.dart';
import 'package:flutter/foundation.dart';

class AiChatController extends ChangeNotifier {
  AiChatController({this.historyLimit = 30});

  final int historyLimit;
  final AiChatApi _api = AiChatApi();

  List<AiChatMessage> _messages = const [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  String? _pendingText;

  List<AiChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    final cached = await _api.loadCachedConversation();
    if (cached.isNotEmpty) {
      _messages = cached;
      notifyListeners();
    }
    await refreshHistory();
  }

  Future<void> refreshHistory() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final history = await _api.fetchHistory(limit: historyLimit);
      _messages = history;
      await _api.cacheConversation(history);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) {
      return;
    }

    _isSending = true;
    _pendingText = trimmed;

    final updated = [..._messages];
    updated.add(
      AiChatMessage(
        id: 'local-user-${DateTime.now().millisecondsSinceEpoch}',
        role: AiChatRole.user,
        content: trimmed,
        createdAt: DateTime.now(),
        isLocalOnly: true,
      ),
    );
    updated.add(AiChatMessage.placeholderAssistant());
    _messages = updated;
    notifyListeners();

    try {
      final reply = await _api.sendMessage(trimmed);
      _replacePlaceholder(reply);
      _isSending = false;
      _pendingText = null;
      await _api.cacheConversation(_messages);
      notifyListeners();
    } catch (error) {
      _markPlaceholderError(error.toString());
      _isSending = false;
      notifyListeners();
    }
  }

  void _replacePlaceholder(AiChatMessage reply) {
    final index = _messages.lastIndexWhere(
      (message) => message.role == AiChatRole.assistant && message.isPending,
    );

    if (index == -1) {
      _messages = [..._messages, reply];
      return;
    }

    final updated = [..._messages];
    updated[index] = reply;
    _messages = updated;
  }

  void _markPlaceholderError(String message) {
    final index = _messages.lastIndexWhere(
      (msg) => msg.role == AiChatRole.assistant && msg.isPending,
    );

    if (index == -1) return;

    final updated = [..._messages];
    updated[index] = updated[index].copyWith(
      isPending: false,
      isError: true,
      errorMessage: message,
    );

    _messages = updated;
  }

  Future<void> retryLast() async {
    if (_isSending) return;

    final lastUserIndex = _messages.lastIndexWhere(
      (message) => message.role == AiChatRole.user,
    );

    if (lastUserIndex == -1) return;
    final text = _messages[lastUserIndex].content.trim();
    if (text.isEmpty) return;

    _isSending = true;
    _pendingText = text;

    final updated = [..._messages];
    if (updated.isNotEmpty) {
      final last = updated.last;
      if (last.role == AiChatRole.assistant &&
          (last.isError || last.isPending)) {
        updated.removeLast();
      }
    }

    updated[lastUserIndex] = updated[lastUserIndex].copyWith(
      isError: false,
      errorMessage: null,
    );
    updated.add(AiChatMessage.placeholderAssistant());
    _messages = updated;
    notifyListeners();

    try {
      final reply = await _api.sendMessage(text);
      _replacePlaceholder(reply);
      _isSending = false;
      _pendingText = null;
      await _api.cacheConversation(_messages);
      notifyListeners();
    } catch (error) {
      _markPlaceholderError(error.toString());
      _isSending = false;
      notifyListeners();
    }
  }
}
