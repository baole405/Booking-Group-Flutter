import 'dart:convert';

import 'package:booking_group_flutter/core/constants/api_constants.dart';
import 'package:booking_group_flutter/models/join_request.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class JoinRequestApi {
  /// Get bearer token from SharedPreferences
  Future<String?> _getBearerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('bearerToken');
  }

  /// Get my join requests
  Future<List<JoinRequest>> getMyJoinRequests() async {
    try {
      final token = await _getBearerToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/joins/my-requests'),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      print('📋 Get my join requests - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((json) => JoinRequest.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load join requests: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting join requests: $e');
      rethrow;
    }
  }

  /// Join a group (create join request)
  Future<bool> joinGroup(int groupId) async {
    try {
      final token = await _getBearerToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/joins/$groupId'),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      print('✉️ Join group - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Join request sent successfully');
        return true;
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to join group');
      }
    } catch (e) {
      print('❌ Error joining group: $e');
      rethrow;
    }
  }

  /// Cancel join request
  Future<bool> cancelJoinRequest(int joinId) async {
    try {
      final token = await _getBearerToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/joins/$joinId'),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      print('🗑️ Cancel join request - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Join request cancelled successfully');
        return true;
      } else {
        throw Exception(
          'Failed to cancel join request: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error cancelling join request: $e');
      rethrow;
    }
  }

  /// Get pending join requests for a group (for group members)
  Future<List<JoinRequest>> getPendingJoinRequests(int groupId) async {
    try {
      final token = await _getBearerToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/joins/$groupId/pending'),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      print('📋 Get pending join requests - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((json) => JoinRequest.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load pending requests: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error getting pending requests: $e');
      rethrow;
    }
  }
}
