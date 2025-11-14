import 'dart:convert';

import 'package:booking_group_flutter/core/constants/api_constants.dart';
import 'package:booking_group_flutter/models/comment.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommentsApi {
  Future<String?> _getBearerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('bearerToken');
  }

  Future<List<Comment>> getCommentsByPost(int postId) async {
    try {
      final headers = <String, String>{'accept': '*/*'};
      final token = await _getBearerToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse(ApiConstants.getPostCommentsUrl(postId)),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] as List<dynamic>? ?? [];
        return data
            .map((item) => Comment.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw Exception(
        'Failed to load comments: ${response.statusCode}',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Comment> createComment({
    required int postId,
    required String content,
  }) async {
    try {
      final token = await _getBearerToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse(ApiConstants.commentsUrl),
        headers: ApiConstants.authHeaders(token),
        body: jsonEncode({
          'postId': postId,
          'content': content,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'] as Map<String, dynamic>? ?? {};
        return Comment.fromJson(data);
      }

      final Map<String, dynamic> errorResponse = json.decode(response.body);
      final message = errorResponse['message'] ?? 'Failed to create comment';
      throw Exception(message);
    } catch (e) {
      rethrow;
    }
  }
}
