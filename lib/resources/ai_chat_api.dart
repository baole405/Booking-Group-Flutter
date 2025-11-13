import 'dart:convert';

import 'package:booking_group_flutter/core/constants/api_constants.dart';
import 'package:booking_group_flutter/features/ai_chat/models/ai_chat_message.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AiChatApi {
  static const _cacheKey = 'ai_chat_cached_messages_v1';
  static const _throttleText = 'Nh\u1eabn t\u1eeb t\u1eeb th\u00f4i';

  Future<String> _requireToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('bearerToken');
    if (token == null || token.isEmpty) {
      throw Exception('Missing authentication token. Please sign in again.');
    }
    return token;
  }

  Future<List<AiChatMessage>> fetchHistory({int limit = 30}) async {
    final token = await _requireToken();
    final uri = Uri.parse(ApiConstants.chatbotHistoryUrl(limit: limit));
    final response = await http.get(
      uri,
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      final payload = _unwrapData(response.body);
      final history = _coerceMessages(payload);
      if (history.isNotEmpty) {
        return history;
      }
      return const [];
    }

    throw Exception('Unable to load chatbot history (${response.statusCode}).');
  }

  Future<AiChatMessage> sendMessage(String text) async {
    final token = await _requireToken();
    final uri = Uri.parse(ApiConstants.chatbotUrl);
    final response = await http.post(
      uri,
      headers: ApiConstants.authHeaders(token),
      body: jsonEncode({'message': text}),
    );

    if (response.statusCode == 200) {
      final payload = _unwrapData(response.body);
      final message = _coerceSingleMessage(payload);
      if (message != null) {
        return message;
      }

      throw Exception('Chatbot returned an empty response.');
    }

    final friendly = _tryBuildThrottleMessage(response);
    if (friendly != null) {
      return friendly;
    }

    final message =
        response.body.isNotEmpty ? response.body : 'Server did not respond';
    throw Exception('Chatbot error (${response.statusCode}): $message');
  }

  Future<void> cacheConversation(List<AiChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final payload =
        messages.map((message) => message.toJson()).toList(growable: false);
    await prefs.setString(_cacheKey, jsonEncode(payload));
  }

  Future<List<AiChatMessage>> loadCachedConversation() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached == null || cached.isEmpty) return const [];

    try {
      final list = jsonDecode(cached);
      return _parseMessages(list);
    } catch (_) {
      return const [];
    }
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  List<AiChatMessage> _parseMessages(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(AiChatMessage.fromJson)
          .toList(growable: false);
    }
    return const [];
  }

  dynamic _unwrapData(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded['data'] ?? decoded;
    }
    return decoded;
  }

  List<AiChatMessage> _coerceMessages(dynamic payload) {
    if (payload is List) {
      return _parseMessages(payload);
    }

    if (payload is Map<String, dynamic>) {
      final history = payload['messages'] ?? payload['history'];
      if (history is List) {
        return _parseMessages(history);
      }

      final conversation = payload['conversation'] ?? payload['responses'];
      if (conversation is List) {
        return _parseMessages(conversation);
      }

      if (payload.containsKey('answer') || payload.containsKey('message')) {
        return [_buildAssistantMessage(payload)];
      }
    }

    return const [];
  }

  AiChatMessage? _coerceSingleMessage(dynamic payload) {
    if (payload is List) {
      final messages = _parseMessages(payload);
      if (messages.isNotEmpty) {
        return messages.last;
      }
      return null;
    }

    if (payload is Map<String, dynamic>) {
      if (_looksLikeMessage(payload)) {
        return AiChatMessage.fromJson(payload);
      }

      final messages = payload['messages'] ?? payload['history'];
      if (messages is List && messages.isNotEmpty) {
        return _parseMessages(messages).last;
      }

      final conversation = payload['conversation'] ?? payload['responses'];
      if (conversation is List && conversation.isNotEmpty) {
        return _parseMessages(conversation).last;
      }

      if (payload.containsKey('answer') || payload.containsKey('message')) {
        return _buildAssistantMessage(payload);
      }
    }

    return null;
  }

  bool _looksLikeMessage(Map<String, dynamic> data) {
    return data.containsKey('role') && data.containsKey('content');
  }

  AiChatMessage _buildAssistantMessage(Map<String, dynamic> data) {
    final answer = (data['answer'] ?? data['message'] ?? '').toString();
    final attachments = data['attachments'] ?? data['attachment'];
    final createdAt = data['createdAt'] ?? DateTime.now().toIso8601String();
    final hasAttachmentData = _hasAttachmentData(attachments);

    final isOverloaded = _isOverloadedError(data, answer);
    final containsBackendError =
        data.containsKey('error') || _looksLikeGeminiError(answer);

    final sanitizedContent = isOverloaded
        ? _throttleText
        : containsBackendError && hasAttachmentData
            ? ''
            : answer;

    final payload = <String, dynamic>{
      'id': data['id'] ??
          data['messageId'] ??
          'assistant-${DateTime.now().millisecondsSinceEpoch}',
      'role': data['role'] ?? 'ASSISTANT',
      'content': sanitizedContent,
      'createdAt': createdAt,
      if (attachments != null) 'attachments': attachments,
    };

    return AiChatMessage.fromJson(payload);
  }

  bool _looksLikeGeminiError(String content) {
    final lower = content.toLowerCase();
    return lower.contains('gemini error') ||
        lower.contains('model is overloaded') ||
        lower.contains('unavailable') ||
        lower.contains('code": 503') ||
        lower.contains('code 503') ||
        lower.contains('rate limit') ||
        lower.contains('overloaded');
  }

  bool _isOverloadedError(Map<String, dynamic> data, String content) {
    bool checkMap(Map<String, dynamic> map) {
      final code = map['code'];
      final status = map['status']?.toString().toUpperCase();
      final message = map['message']?.toString().toLowerCase();

      bool codeMatch = false;
      if (code is int) {
        codeMatch = code == 503 || code == 429;
      } else if (code is String) {
        final lower = code.toLowerCase();
        codeMatch = lower.contains('503') || lower.contains('429');
      }

      final messageMatch = message != null &&
          (message.contains('overloaded') ||
              message.contains('unavailable') ||
              message.contains('rate limit'));

      if (codeMatch || messageMatch || status == 'UNAVAILABLE') {
        return true;
      }

      for (final value in map.values) {
        if (value is Map<String, dynamic> && checkMap(value)) {
          return true;
        }
      }
      return false;
    }

    if (data['error'] is Map<String, dynamic> &&
        checkMap(data['error'] as Map<String, dynamic>)) {
      return true;
    }

    return _looksLikeGeminiError(content);
  }

  bool _hasAttachmentData(dynamic attachments) {
    if (attachments is Map<String, dynamic>) {
      return attachments.isNotEmpty;
    }
    if (attachments is List) {
      return attachments.isNotEmpty;
    }
    return false;
  }

  AiChatMessage? _tryBuildThrottleMessage(http.Response response) {
    final lower = response.body.toLowerCase();
    if (response.statusCode == 503 ||
        response.statusCode == 429 ||
        lower.contains('503') ||
        lower.contains('429') ||
        lower.contains('overloaded') ||
        lower.contains('unavailable')) {
      return _buildThrottleReply();
    }
    return null;
  }

  AiChatMessage _buildThrottleReply() {
    return AiChatMessage(
      id: 'assistant-${DateTime.now().millisecondsSinceEpoch}',
      role: AiChatRole.assistant,
      content: _throttleText,
      createdAt: DateTime.now(),
    );
  }
}
