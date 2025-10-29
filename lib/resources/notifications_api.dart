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
}
