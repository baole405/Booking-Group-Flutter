import 'dart:async';

import 'package:booking_group_flutter/core/services/api_service.dart';
import 'package:booking_group_flutter/models/chat_message.dart';
import 'package:booking_group_flutter/resources/chat_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Controller that manages chat state, polling and mutations.
class ChatController extends ChangeNotifier {
  ChatController({required this.groupId});

  final int groupId;
  final ChatApi _chatApi = ChatApi();
  Timer? _pollingTimer;

  List<ChatMessage> _messages = const [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isSending = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  int? _currentUserId;
  String? _errorMessage;
  String? _currentUserEmail;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isSending => _isSending;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  bool get isMutating => _isSending || _isUpdating || _isDeleting;
  String? get errorMessage => _errorMessage;
  int? get currentUserId => _currentUserId;
  String? get currentUserEmail => _currentUserEmail;

  /// Initializes the controller by loading the first page and starting polling.
  Future<void> initialize() async {
    await _loadCurrentUserIdentity();
    await refreshMessages(showLoading: true);
    _startPolling();
  }

  Future<void> _loadCurrentUserIdentity() async {
    _currentUserEmail = FirebaseAuth.instance.currentUser?.email?.toLowerCase();

    try {
      final myInfo = await ApiService().getMyInfo();
      if (myInfo != null) {
        final backendEmail = (myInfo['email'] as String?)?.toLowerCase();
        final backendId = myInfo['id'];

        _currentUserEmail ??= backendEmail;
        final parsedId = backendId is int
            ? backendId
            : backendId is num
                ? backendId.toInt()
                : backendId is String
                    ? int.tryParse(backendId)
                    : null;
        if (parsedId != null) {
          _currentUserId = parsedId;
        }
      }
    } catch (error) {
      debugPrint('ChatController: failed to load user identity -> $error');
    }
  }

  Future<void> refreshMessages({bool showLoading = false}) async {
    if (_isLoading || _isRefreshing) {
      return;
    }

    if (showLoading) {
      _isLoading = true;
    } else {
      _isRefreshing = true;
    }
    notifyListeners();

    try {
      final fetched = await _chatApi.getGroupMessages(groupId);
      fetched.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      _messages = fetched;
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      if (showLoading) {
        _isLoading = false;
      } else {
        _isRefreshing = false;
      }
      notifyListeners();
    }
  }

  Future<void> sendMessage(
    String content, {
    int? replyToMessageId,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty || _isSending) {
      return;
    }

    _isSending = true;
    notifyListeners();

    try {
      await _chatApi.sendMessage(
        groupId: groupId,
        content: trimmed,
        replyToMessageId: replyToMessageId,
      );
      await refreshMessages();
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> updateMessage(int messageId, String content) async {
    final trimmed = content.trim();
    if (messageId <= 0 || trimmed.isEmpty || _isUpdating) {
      return;
    }

    _isUpdating = true;
    notifyListeners();

    try {
      await _chatApi.updateMessage(
        messageId: messageId,
        content: trimmed,
      );
      await refreshMessages();
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<void> deleteMessage(int messageId) async {
    if (messageId <= 0 || _isDeleting) {
      return;
    }

    _isDeleting = true;
    notifyListeners();

    try {
      await _chatApi.deleteMessage(messageId);
      await refreshMessages();
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  Future<List<ChatMessage>> searchMessages(String keyword) async {
    try {
      return await _chatApi.searchMessages(
        groupId: groupId,
        keyword: keyword,
      );
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      refreshMessages();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
