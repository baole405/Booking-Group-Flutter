import 'dart:convert';

import 'package:booking_group_flutter/core/constants/api_constants.dart';
import 'package:booking_group_flutter/models/invite.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InviteApi {
  Future<String?> _getBearerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('bearerToken');
  }

  Future<Invite> createInvite({
    required int groupId,
    required int inviteeId,
  }) async {
    final token = await _getBearerToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse(ApiConstants.invitesUrl),
      headers: ApiConstants.authHeaders(token),
      body: jsonEncode({
        'groupId': groupId,
        'inviteeId': inviteeId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final data = jsonResponse['data'] as Map<String, dynamic>? ?? {};
      return Invite.fromJson(data);
    }

    final Map<String, dynamic> errorResponse = json.decode(response.body);
    final message = errorResponse['message'] ?? 'Failed to create invite';
    throw Exception(message);
  }

  Future<MyInvites> getMyInvites({
    InviteStatus? status,
    int receivedPage = 1,
    int receivedSize = 10,
    int sentPage = 1,
    int sentSize = 10,
  }) async {
    final token = await _getBearerToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse(
        ApiConstants.getMyInvitesUrl(
          status: status,
          receivedPage: receivedPage,
          receivedSize: receivedSize,
          sentPage: sentPage,
          sentSize: sentSize,
        ),
      ),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final data = jsonResponse['data'] as Map<String, dynamic>? ?? {};
      return MyInvites.fromJson(data);
    }

    throw Exception('Failed to load invites: ${response.statusCode}');
  }

  Future<Invite> respondToInvite({
    required int inviteId,
    required InviteStatus status,
  }) async {
    final token = await _getBearerToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.patch(
      Uri.parse(ApiConstants.updateInviteStatusUrl(inviteId)),
      headers: ApiConstants.authHeaders(token),
      body: jsonEncode({'status': status.backendValue}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final data = jsonResponse['data'] as Map<String, dynamic>? ?? {};
      return Invite.fromJson(data);
    }

    final Map<String, dynamic> errorResponse = json.decode(response.body);
    final message = errorResponse['message'] ?? 'Failed to update invite';
    throw Exception(message);
  }
}
