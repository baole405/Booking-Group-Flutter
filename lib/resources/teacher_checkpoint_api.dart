import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/api_constants.dart';
import '../models/user_profile.dart';

class TeacherCheckpointApi {
  /// Get list of all teachers/lecturers
  Future<List<UserProfile>> getTeacherList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/teacher-checkpoints/teachers'),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['status'] == 200 && data['data'] != null) {
        return (data['data'] as List)
            .map((item) => UserProfile.fromJson(item))
            .toList();
      }
      throw Exception(data['message'] ?? 'Failed to load teachers');
    }
    throw Exception('Failed to load teachers: ${response.statusCode}');
  }

  /// Request a teacher to be assigned to the group (Leader action)
  Future<String> requestTeacherCheckpoint(int teacherId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.post(
      Uri.parse(
        '${ApiConstants.baseUrl}/api/teacher-checkpoints/teachers/$teacherId',
      ),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['message'] ?? 'Request sent successfully';
    }
    throw Exception('Failed to request teacher: ${response.statusCode}');
  }

  /// Get my group's teacher request status
  Future<Map<String, dynamic>?> getMyTeacherRequest(int groupId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/api/teacher-checkpoints/groups/$groupId/my-request',
      ),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['status'] == 200) {
        return data['data'];
      }
    }
    return null;
  }
}
