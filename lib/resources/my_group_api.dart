import 'dart:convert';

import 'package:booking_group_flutter/core/constants/api_constants.dart';
import 'package:booking_group_flutter/models/group_member.dart';
import 'package:booking_group_flutter/models/idea.dart';
import 'package:booking_group_flutter/models/my_group.dart';
import 'package:booking_group_flutter/models/user_profile.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// API Service for My Group operations
class MyGroupApi {
  /// Get bearer token from SharedPreferences
  Future<String?> _getBearerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('bearerToken');
  }

  /// Get the current user's group
  Future<MyGroup?> getMyGroup() async {
    try {
      final token = await _getBearerToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('🔄 Fetching my group from: ${ApiConstants.myGroupUrl}');

      final response = await http.get(
        Uri.parse(ApiConstants.myGroupUrl),
        headers: ApiConstants.authHeaders(token),
      );

      print('📊 My Group Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        print('📦 Response data: ${jsonResponse['data']}'); // Debug log

        if (jsonResponse['status'] == 200 && jsonResponse['data'] != null) {
          try {
            final myGroup = MyGroup.fromJson(jsonResponse['data']);
            print('✅ My group loaded: ${myGroup.title}');
            return myGroup;
          } catch (e) {
            print('❌ Error parsing MyGroup: $e');
            print('📦 Raw data: ${jsonResponse['data']}');
            rethrow;
          }
        }
      } else if (response.statusCode == 404) {
        print('⚠️ User is not in any group');
        return null;
      } else if (response.statusCode == 500) {
        // Backend might be having issues or user relationship not ready
        print('❌ Server error 500 - Backend might be processing the request');
        print('📦 Response body: ${response.body}');
        throw Exception('Server error - Please try again in a moment');
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load my group: ${response.statusCode}');
      }

      return null;
    } catch (e) {
      print('❌ Error in getMyGroup: $e');
      rethrow;
    }
  }

  /// Get members of a specific group
  Future<List<GroupMember>> getGroupMembers(int groupId) async {
    try {
      final token = await _getBearerToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = ApiConstants.getGroupMembersUrl(groupId);
      print('🔄 Fetching group members from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.authHeaders(token),
      );

      print('📊 Group Members Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

        if (jsonResponse['status'] == 200 && jsonResponse['data'] != null) {
          final List<dynamic> membersJson = jsonResponse['data'] as List;
          final members = membersJson
              .map((json) => GroupMember.fromJson(json))
              .toList();

          print('✅ ${members.length} members loaded');
          return members;
        }
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load group members: ${response.statusCode}');
      }

      return [];
    } catch (e) {
      print('❌ Error in getGroupMembers: $e');
      rethrow;
    }
  }

  /// Get ideas of a specific group
  Future<List<Idea>> getGroupIdeas(int groupId) async {
    try {
      final token = await _getBearerToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = ApiConstants.getGroupIdeasUrl(groupId);
      print('🔄 Fetching group ideas from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.authHeaders(token),
      );

      print('📊 Group Ideas Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

        if (jsonResponse['status'] == 200 && jsonResponse['data'] != null) {
          final List<dynamic> ideasJson = jsonResponse['data'] as List;
          final ideas = ideasJson.map((json) => Idea.fromJson(json)).toList();

          print('✅ ${ideas.length} ideas loaded');
          return ideas;
        }
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load group ideas: ${response.statusCode}');
      }

      return [];
    } catch (e) {
      print('❌ Error in getGroupIdeas: $e');
      rethrow;
    }
  }

  /// Get the leader of a specific group
  Future<UserProfile?> getGroupLeader(int groupId) async {
    try {
      final token = await _getBearerToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = ApiConstants.getGroupLeaderUrl(groupId);
      print('🔄 Fetching group leader from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.authHeaders(token),
      );

      print('📊 Group Leader Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

        if (jsonResponse['status'] == 200 && jsonResponse['data'] != null) {
          final leader = UserProfile.fromJson(jsonResponse['data']);
          print('✅ Leader loaded: ${leader.fullName}');
          return leader;
        }
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load group leader: ${response.statusCode}');
      }

      return null;
    } catch (e) {
      print('❌ Error in getGroupLeader: $e');
      rethrow;
    }
  }

  /// Update an idea (Leader only)
  Future<bool> updateIdea({
    required int ideaId,
    required String title,
    required String description,
  }) async {
    try {
      final token = await _getBearerToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = ApiConstants.getIdeaUrl(ideaId);
      print('🔄 Updating idea at: $url');

      final response = await http.put(
        Uri.parse(url),
        headers: ApiConstants.authHeaders(token),
        body: jsonEncode({'title': title, 'description': description}),
      );

      print('📊 Update Idea Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Idea updated successfully');
        return true;
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to update idea: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in updateIdea: $e');
      rethrow;
    }
  }

  /// Create a new idea (Leader only)
  Future<bool> createIdea({
    required String title,
    required String description,
  }) async {
    try {
      final token = await _getBearerToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = ApiConstants.ideasUrl;
      print('🔄 Creating idea at: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: ApiConstants.authHeaders(token),
        body: jsonEncode({'title': title, 'description': description}),
      );

      print('📊 Create Idea Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Idea created successfully');
        return true;
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to create idea: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in createIdea: $e');
      rethrow;
    }
  }

  /// Delete an idea (Leader only)
  Future<bool> deleteIdea(int ideaId) async {
    try {
      final token = await _getBearerToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = ApiConstants.getIdeaUrl(ideaId);
      print('🔄 Deleting idea at: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: ApiConstants.authHeaders(token),
      );

      print('📊 Delete Idea Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Idea deleted successfully');
        return true;
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to delete idea: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in deleteIdea: $e');
      rethrow;
    }
  }
}
