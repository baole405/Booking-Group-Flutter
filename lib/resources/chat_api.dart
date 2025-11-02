import 'dart:convert';

import 'package:booking_group_flutter/core/constants/api_constants.dart';
import 'package:booking_group_flutter/models/chat_message.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// REST client for the chat module.
class ChatApi {
  Future<String> _requireToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('bearerToken');
    if (token == null || token.isEmpty) {
      throw Exception('Missing authentication token. Please sign in again.');
    }
    return token;
  }

  Map<String, dynamic> _decodeJsonBody(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    return jsonDecode(body) as Map<String, dynamic>;
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final content = data['content'];
      if (content is List) {
        return content;
      }
    }
    return const [];
  }

  String _extractMessage(String body, String fallback) {
    try {
      final json = _decodeJsonBody(body);
      final message = json['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    } catch (_) {
      // Ignore errors and fallback to provided message.
    }
    return fallback;
  }

  Future<List<ChatMessage>> getGroupMessages(
    int groupId, {
    int page = 1,
    int size = 50,
  }) async {
    if (groupId <= 0) {
      return const [];
    }

    final token = await _requireToken();
    final response = await http.get(
      Uri.parse(ApiConstants.getGroupChatMessagesUrl(groupId, page: page, size: size)),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      final json = _decodeJsonBody(response.body);
      final list = _extractList(json['data']);
      return list
          .whereType<Map<String, dynamic>>()
          .map(ChatMessage.fromJson)
          .toList();
    }

    final message = _extractMessage(
      response.body,
      'Failed to load group messages (${response.statusCode}).',
    );
    throw Exception(message);
  }

  Future<ChatMessage> sendMessage({
    required int groupId,
    required String content,
    int? replyToMessageId,
  }) async {
    if (groupId <= 0) {
      throw Exception('Invalid group identifier.');
    }

    final token = await _requireToken();
    final payload = <String, dynamic>{
      'groupId': groupId,
      'content': content,
    };

    if (replyToMessageId != null && replyToMessageId > 0) {
      payload['replyToMessageId'] = replyToMessageId;
    }

    final response = await http.post(
      Uri.parse(ApiConstants.createChatMessageUrl()),
      headers: ApiConstants.authHeaders(token),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = _decodeJsonBody(response.body);
      final data = json['data'];
      if (data is Map<String, dynamic>) {
        return ChatMessage.fromJson(data);
      }
      if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
        return ChatMessage.fromJson(data.first as Map<String, dynamic>);
      }
      return ChatMessage.fromJson(json);
    }

    final message = _extractMessage(
      response.body,
      'Failed to send message (${response.statusCode}).',
    );
    throw Exception(message);
  }

  Future<ChatMessage> updateMessage({
    required int messageId,
    required String content,
  }) async {
    if (messageId <= 0) {
      throw Exception('Invalid message identifier.');
    }

    final token = await _requireToken();
    final response = await http.put(
      Uri.parse(ApiConstants.updateChatMessageUrl(messageId)),
      headers: {
        ...ApiConstants.authHeaders(token),
        'Content-Type': 'text/plain; charset=utf-8',
      },
      body: content,
    );

    if (response.statusCode == 200) {
      final json = _decodeJsonBody(response.body);
      final data = json['data'];
      if (data is Map<String, dynamic>) {
        return ChatMessage.fromJson(data);
      }
      return ChatMessage.fromJson(json);
    }

    final message = _extractMessage(
      response.body,
      'Failed to update message (${response.statusCode}).',
    );
    throw Exception(message);
  }

  Future<void> deleteMessage(int messageId) async {
    if (messageId <= 0) {
      throw Exception('Invalid message identifier.');
    }

    final token = await _requireToken();
    final response = await http.delete(
      Uri.parse(ApiConstants.deleteChatMessageUrl(messageId)),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    final message = _extractMessage(
      response.body,
      'Failed to delete message (${response.statusCode}).',
    );
    throw Exception(message);
  }

  Future<ChatMessage?> getMessageDetail(int messageId) async {
    if (messageId <= 0) {
      return null;
    }

    final token = await _requireToken();
    final response = await http.get(
      Uri.parse(ApiConstants.getChatMessageDetailUrl(messageId)),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      final json = _decodeJsonBody(response.body);
      final data = json['data'];
      if (data is Map<String, dynamic>) {
        return ChatMessage.fromJson(data);
      }
      return ChatMessage.fromJson(json);
    }

    if (response.statusCode == 404) {
      return null;
    }

    final message = _extractMessage(
      response.body,
      'Failed to load message detail (${response.statusCode}).',
    );
    throw Exception(message);
  }

  Future<List<ChatMessage>> searchMessages({
    required int groupId,
    required String keyword,
    int page = 1,
    int size = 50,
  }) async {
    if (groupId <= 0 || keyword.trim().length < 2) {
      return const [];
    }

    final token = await _requireToken();
    final response = await http.get(
      Uri.parse(
        ApiConstants.searchGroupChatMessagesUrl(
          groupId,
          keyword,
          page: page,
          size: size,
        ),
      ),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      final json = _decodeJsonBody(response.body);
      final list = _extractList(json['data']);
      return list
          .whereType<Map<String, dynamic>>()
          .map(ChatMessage.fromJson)
          .toList();
    }

    final message = _extractMessage(
      response.body,
      'Failed to search messages (${response.statusCode}).',
    );
    throw Exception(message);
  }
}
