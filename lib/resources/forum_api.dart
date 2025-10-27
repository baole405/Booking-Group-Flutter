import 'dart:convert';

import 'package:booking_group_flutter/core/constants/api_constants.dart';
import 'package:booking_group_flutter/models/idea.dart';
import 'package:booking_group_flutter/models/post.dart';
import 'package:http/http.dart' as http;

class ForumApi {
  /// Get all posts
  Future<List<Post>> getAllPosts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/posts'),
        headers: {'accept': '*/*'},
      );

      print('📝 Get all posts - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting posts: $e');
      rethrow;
    }
  }

  /// Get all ideas (admin/teacher only)
  Future<List<Idea>> getAllIdeas() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/ideas'),
        headers: {'accept': '*/*'},
      );

      print('💡 Get all ideas - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((json) => Idea.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load ideas: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting ideas: $e');
      rethrow;
    }
  }
}
