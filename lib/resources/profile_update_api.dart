import 'dart:convert';

import 'package:booking_group_flutter/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// API Service for Profile Update operations
class ProfileUpdateApi {
  /// Get bearer token from SharedPreferences
  Future<String?> _getBearerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('bearerToken');
  }

  /// Update user profile (cvUrl, avatarUrl, majorId)
  Future<bool> updateProfile({
    String? cvUrl,
    String? avatarUrl,
    int? majorId,
  }) async {
    try {
      final token = await _getBearerToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('🔄 Updating profile: ${ApiConstants.updateMyInfoUrl}');

      // Build request body (only include non-null fields)
      final Map<String, dynamic> requestBody = {};
      if (cvUrl != null) requestBody['cvUrl'] = cvUrl;
      if (avatarUrl != null) requestBody['avatarUrl'] = avatarUrl;
      if (majorId != null) requestBody['majorId'] = majorId;

      print('📤 Request body: $requestBody');

      final response = await http.put(
        Uri.parse(ApiConstants.updateMyInfoUrl),
        headers: ApiConstants.authHeaders(token),
        body: jsonEncode(requestBody),
      );

      print('📊 Update Profile Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

        if (jsonResponse['status'] == 200 ||
            jsonResponse['status'] == 1073741824) {
          print('✅ Profile updated successfully');
          return true;
        }
      }

      print('❌ Failed to update profile: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Error in updateProfile: $e');
      rethrow;
    }
  }

  /// Update major only (convenience method)
  Future<bool> updateMajor(int majorId) async {
    return updateProfile(majorId: majorId);
  }
}
