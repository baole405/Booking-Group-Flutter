import 'dart:convert';

import 'package:booking_group_flutter/core/constants/api_constants.dart';
import 'package:booking_group_flutter/models/app_notification.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsApi {
  Future<String?> _getBearerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('bearerToken');
  }

  Future<List<AppNotification>> fetchNotifications() async {
    final token = await _getBearerToken();
    if (token == null) {
      throw Exception('Missing authentication token');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.notificationsUrl),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load notifications (${response.statusCode})');
    }

    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final dynamic data = jsonResponse['data'];

    final Iterable items;
    if (data is List) {
      items = data;
    } else if (data is Map<String, dynamic>) {
      final content = data['content'];
      if (content is List) {
        items = content;
      } else {
        items = const [];
      }
    } else {
      items = const [];
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList()
      ..sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
  }

  Future<AppNotification> markAsRead(int notificationId) async {
    final token = await _getBearerToken();
    if (token == null) {
      throw Exception('Missing authentication token');
    }

    final response = await http.patch(
      Uri.parse(ApiConstants.markNotificationAsReadUrl(notificationId)),
      headers: ApiConstants.authHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to mark notification as read (${response.statusCode})',
      );
    }

    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final data = jsonResponse['data'];
    if (data is Map<String, dynamic>) {
      return AppNotification.fromJson(data);
    }

    return AppNotification(
      id: notificationId,
      title: 'Notification',
      message: '',
      isRead: true,
      createdAt: null,
    );
  }

  Future<void> sendMemberRemovedNotification({
    required int userId,
    required String groupName,
  }) async {
    final token = await _getBearerToken();
    if (token == null) {
      throw Exception('Missing authentication token');
    }

    final message =
        'B\u1ea1n \u0111\u00e3 b\u1ecb xo\u00e1 kh\u1ecfi nh\u00f3m $groupName.';

    final response = await http.post(
      Uri.parse(ApiConstants.notificationsUrl),
      headers: ApiConstants.authHeaders(token),
      body: jsonEncode({
        'receiverId': userId,
        'title': 'C\u1eadp nh\u1eadt nh\u00f3m',
        'message': message,
        'type': 'GROUP_REMOVAL',
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Kh\u00f4ng th\u1ec3 g\u1eedi th\u00f4ng b\u00e1o (status: ${response.statusCode})',
      );
    }
  }
}
