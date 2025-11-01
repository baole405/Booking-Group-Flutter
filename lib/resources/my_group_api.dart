import 'dart:convert';

import 'package:booking_group_flutter/core/constants/api_constants.dart';
import 'package:booking_group_flutter/models/group_member.dart';
import 'package:booking_group_flutter/models/idea.dart';
import 'package:booking_group_flutter/models/my_group.dart';
import 'package:booking_group_flutter/models/user_profile.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Data-source wrapper for group-related endpoints that the current user can access.
class MyGroupApi {
  Future<String?> _getBearerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('bearerToken');
  }

  Future<String> _requireToken() async {
    final token = await _getBearerToken();
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
    if (data is List) {
      return data;
    }
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
      // Ignore decode failures and fallback to provided message.
    }
    return fallback;
  }

  Future<MyGroup?> getMyGroup() async {
    final token = await _requireToken();
    final response = await http.get(
      Uri.parse(ApiConstants.myGroupUrl),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      final json = _decodeJsonBody(response.body);
      final data = json['data'];
      if (data != null) {
        return MyGroup.fromJson(data as Map<String, dynamic>);
      }
      return null;
    }

    if (response.statusCode == 404) {
      return null;
    }

    final message = _extractMessage(
      response.body,
      'Failed to load group (${response.statusCode}).',
    );
    throw Exception(message);
  }

  Future<List<GroupMember>> getGroupMembers(int groupId) async {
    final token = await _requireToken();
    final response = await http.get(
      Uri.parse(ApiConstants.getGroupMembersUrl(groupId)),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      final json = _decodeJsonBody(response.body);
      final list = _extractList(json['data']);
      return list
          .whereType<Map<String, dynamic>>()
          .map(GroupMember.fromJson)
          .toList();
    }

    final message = _extractMessage(
      response.body,
      'Failed to load group members (${response.statusCode}).',
    );
    throw Exception(message);
  }

  Future<List<Idea>> getGroupIdeas(int groupId) async {
    final token = await _requireToken();
    final response = await http.get(
      Uri.parse(ApiConstants.getGroupIdeasUrl(groupId)),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      final json = _decodeJsonBody(response.body);
      final list = _extractList(json['data']);
      return list.whereType<Map<String, dynamic>>().map(Idea.fromJson).toList();
    }

    final message = _extractMessage(
      response.body,
      'Failed to load ideas (${response.statusCode}).',
    );
    throw Exception(message);
  }

  Future<UserProfile?> getGroupLeader(int groupId) async {
    final token = await _requireToken();
    final response = await http.get(
      Uri.parse(ApiConstants.getGroupLeaderUrl(groupId)),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      final json = _decodeJsonBody(response.body);
      final data = json['data'];
      if (data == null) return null;
      return UserProfile.fromJson(data as Map<String, dynamic>);
    }

    if (response.statusCode == 404) {
      return null;
    }

    final message = _extractMessage(
      response.body,
      'Failed to load leader (${response.statusCode}).',
    );
    throw Exception(message);
  }

  Future<bool> updateIdea({
    required int ideaId,
    required String title,
    required String description,
  }) async {
    final token = await _requireToken();
    final response = await http.put(
      Uri.parse(ApiConstants.getIdeaUrl(ideaId)),
      headers: ApiConstants.authHeaders(token),
      body: jsonEncode({'title': title, 'description': description}),
    );

    if (response.statusCode == 200) {
      return true;
    }

    final message = _extractMessage(
      response.body,
      'Failed to update idea (${response.statusCode}).',
    );
    throw Exception(message);
  }

  Future<void> updateGroupInfo({
    required int groupId,
    required String title,
    required String description,
  }) async {
    final token = await _requireToken();
    final response = await http.put(
      Uri.parse(ApiConstants.updateGroupUrl),
      headers: ApiConstants.authHeaders(token),
      body: jsonEncode({
        'groupId': groupId,
        'title': title,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      return;
    }

    final message = _extractMessage(
      response.body,
      'Failed to update group info (${response.statusCode}).',
    );
    throw Exception(message);
  }

  Future<void> changeGroupType() async {
    final token = await _requireToken();
    final response = await http.patch(
      Uri.parse(ApiConstants.changeGroupTypeUrl),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      return;
    }

    final message = _extractMessage(
      response.body,
      'Failed to change group type (${response.statusCode}).',
    );
    throw Exception(message);
  }

  Future<void> completeGroup() async {
    final token = await _requireToken();
    final response = await http.patch(
      Uri.parse(ApiConstants.completeGroupUrl),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      return;
    }

    final message = _extractMessage(
      response.body,
      'Failed to complete group (${response.statusCode}).',
    );
    throw Exception(message);
  }

  Future<bool> createIdea({
    required String title,
    required String description,
  }) async {
    final token = await _requireToken();
    final response = await http.post(
      Uri.parse(ApiConstants.ideasUrl),
      headers: ApiConstants.authHeaders(token),
      body: jsonEncode({'title': title, 'description': description}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    final message = _extractMessage(
      response.body,
      'Failed to create idea (${response.statusCode}).',
    );
    throw Exception(message);
  }

  Future<bool> deleteIdea(int ideaId) async {
    final token = await _requireToken();
    final response = await http.delete(
      Uri.parse(ApiConstants.getIdeaUrl(ideaId)),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      return true;
    }

    final message = _extractMessage(
      response.body,
      'Failed to delete idea (${response.statusCode}).',
    );
    throw Exception(message);
  }

  Future<void> removeMember(int userId) async {
    final token = await _requireToken();
    final response = await http.delete(
      Uri.parse(ApiConstants.removeMemberUrl(userId)),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      return;
    }

    final message = _extractMessage(
      response.body,
      'Failed to remove member (${response.statusCode}).',
    );
    throw Exception(message);
  }

  Future<void> leaveGroup() async {
    final token = await _requireToken();
    final response = await http.delete(
      Uri.parse(ApiConstants.leaveGroupUrl),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      return;
    }

    final message = _extractMessage(
      response.body,
      'Failed to leave group (${response.statusCode}).',
    );
    throw Exception(message);
  }
}
