import 'dart:convert';

import 'package:booking_group_flutter/core/constants/api_constants.dart';
import 'package:booking_group_flutter/models/major.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// API Service for Major operations
class MajorApi {
  /// Get bearer token from SharedPreferences
  Future<String?> _getBearerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('bearerToken');
  }

  /// Get all majors
  Future<List<Major>> getAllMajors() async {
    try {
      final token = await _getBearerToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('🔄 Fetching majors from: ${ApiConstants.majorsUrl}');

      final response = await http.get(
        Uri.parse(ApiConstants.majorsUrl),
        headers: ApiConstants.authHeaders(token),
      );

      print('📊 Majors Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

        if (jsonResponse['status'] == 200 && jsonResponse['data'] != null) {
          final List<dynamic> majorsJson = jsonResponse['data'] as List;
          final majors = majorsJson
              .map((json) => Major.fromJson(json))
              .toList();

          print('✅ ${majors.length} majors loaded');
          return majors;
        }
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load majors: ${response.statusCode}');
      }

      return [];
    } catch (e) {
      print('❌ Error in getAllMajors: $e');
      rethrow;
    }
  }
}
