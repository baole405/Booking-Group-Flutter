import 'dart:convert';

import 'package:booking_group_flutter/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Get Bearer Token from SharedPreferences
  Future<String?> _getBearerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('bearerToken');
  }

  // Store Bearer Token
  Future<void> storeBearerToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bearerToken', token);
  }

  // Clear Bearer Token (for logout)
  Future<void> clearBearerToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bearerToken');
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _getBearerToken();
    return token != null && token.isNotEmpty;
  }

  // Logout (clear Bearer Token)
  Future<void> logout() async {
    await clearBearerToken();
  }

  // Generic GET request with Bearer Token
  Future<http.Response> get(String endpoint) async {
    final token = await _getBearerToken();

    if (token == null) {
      throw Exception('No Bearer Token found. Please login first.');
    }

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: ApiConstants.authHeaders(token),
    );

    return response;
  }

  // Generic POST request with Bearer Token
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final Map<String, String> headers;

    if (requiresAuth) {
      final token = await _getBearerToken();
      if (token == null) {
        throw Exception('No Bearer Token found. Please login first.');
      }
      headers = ApiConstants.authHeaders(token);
    } else {
      headers = ApiConstants.jsonHeaders;
    }

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    return response;
  }

  // Example: Get User Info
  Future<Map<String, dynamic>?> getMyInfo() async {
    try {
      final response = await get('/api/users/myInfo');

      print('Get My Info Response: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Based on Swagger: { "status": 200, "message": "...", "data": {...} }
        if (data['status'] == 200 && data['data'] != null) {
          return data['data'];
        }
      }

      return null;
    } catch (e) {
      print('Error getting user info: $e');
      rethrow;
    }
  }

  // Login with Google (send idToken, get Bearer Token)
  Future<String?> loginWithGoogle(String idToken) async {
    try {
      print('=====================================');
      print('🔐 Starting Backend Authentication');
      print('=====================================');
      print('Backend URL: ${ApiConstants.googleLoginUrl}');
      print('Firebase ID Token length: ${idToken.length} characters');
      print('Token preview: ${idToken.substring(0, 50)}...');

      final uri = Uri.parse(ApiConstants.googleLoginUrl);
      print('Sending POST request to: $uri');

      final response = await http
          .post(
            uri,
            headers: ApiConstants.jsonHeaders,
            body: jsonEncode({'idToken': idToken}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('⏱️ Request timed out after 30 seconds');
              throw Exception(
                'Request timeout - Backend might be slow or unreachable',
              );
            },
          );

      print('=====================================');
      print('📥 Backend Response Received');
      print('=====================================');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('=====================================');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('✅ Response parsed successfully');
        print('Response structure: ${responseData.keys}');

        // Based on Backend: { "status": 200, "message": "...", "data": { "email": "...", "token": "..." } }
        if (responseData['status'] == 200 && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;
          final String bearerToken = data['token'];
          final String email = data['email'];

          print('✅ Extracted Bearer Token for: $email');
          print('Token length: ${bearerToken.length} characters');
          if (bearerToken.length > 50) {
            print('Token preview: ${bearerToken.substring(0, 50)}...');
          } else {
            print('Token: $bearerToken');
          }

          // Store token
          await storeBearerToken(bearerToken);

          print('✅ Bearer Token stored successfully');
          print('=====================================');
          return bearerToken;
        } else {
          print('❌ Invalid response format from Backend');
          print('Expected: {status: 200, data: {token, email}}');
          print('Got: $responseData');
          throw Exception('Invalid response format from Backend');
        }
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        print('❌ Client Error (${response.statusCode})');
        print(
          'This usually means the request is invalid or authentication failed',
        );
        throw Exception(
          'Backend client error ${response.statusCode}: ${response.body}',
        );
      } else if (response.statusCode >= 500) {
        print('❌ Server Error (${response.statusCode})');
        print('Backend is having issues');
        throw Exception(
          'Backend server error ${response.statusCode}: ${response.body}',
        );
      } else {
        print('❌ Unexpected status code: ${response.statusCode}');
        throw Exception(
          'Unexpected response ${response.statusCode}: ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      print('❌ Network Error: Cannot connect to Backend');
      print('Error: $e');
      print('Possible causes:');
      print('  1. Backend URL is wrong');
      print('  2. Backend is not running');
      print('  3. No internet connection');
      print('  4. Firewall blocking request');
      rethrow;
    } on FormatException catch (e) {
      print('❌ JSON Parse Error: Invalid response format');
      print('Error: $e');
      rethrow;
    } catch (e) {
      print('❌ Unexpected Error during Backend authentication');
      print('Error type: ${e.runtimeType}');
      print('Error: $e');
      rethrow;
    }
  }
}
