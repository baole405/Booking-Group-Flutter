import 'dart:convert';

import 'package:booking_group_flutter/core/constants/api_constants.dart';
import 'package:booking_group_flutter/models/group_member.dart';
import 'package:http/http.dart' as http;

class GroupsApi {
  /// Get group by ID
  Future<Map<String, dynamic>?> getGroupById(int groupId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/groups/$groupId'),
        headers: {'accept': '*/*'},
      );

      print('📋 Get group by ID - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['data'];
      } else {
        throw Exception('Failed to load group: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting group: $e');
      rethrow;
    }
  }

  /// Get group members
  Future<List<GroupMember>> getGroupMembers(int groupId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/groups/$groupId/members'),
        headers: {'accept': '*/*'},
      );

      print('👥 Get group members - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((json) => GroupMember.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load members: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting members: $e');
      rethrow;
    }
  }

  /// Get group member count
  Future<int> getGroupMemberCount(int groupId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/groups/$groupId/members/count'),
        headers: {'accept': '*/*'},
      );

      print('🔢 Get member count - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['data'] ?? 0;
      } else {
        throw Exception('Failed to load member count: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting member count: $e');
      return 0;
    }
  }

  /// Get group leader
  Future<Map<String, dynamic>?> getGroupLeader(int groupId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/groups/$groupId/leader'),
        headers: {'accept': '*/*'},
      );

      print('👑 Get group leader - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['data'];
      } else if (response.statusCode == 404) {
        // Group chưa có leader - trả về null thay vì throw error
        print('ℹ️ Group has no leader yet');
        return null;
      } else {
        throw Exception('Failed to load leader: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting leader: $e');
      // Trả về null thay vì rethrow để không crash app
      return null;
    }
  }
}
