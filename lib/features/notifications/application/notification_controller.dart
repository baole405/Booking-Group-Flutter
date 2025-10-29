import 'dart:async';

import 'package:booking_group_flutter/models/app_notification.dart';
import 'package:booking_group_flutter/resources/notifications_api.dart';
import 'package:flutter/foundation.dart';

class NotificationController extends ChangeNotifier {
  NotificationController({NotificationsApi? api})
      : _api = api ?? NotificationsApi();

  final NotificationsApi _api;

  final List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _initialized = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get initialized => _initialized;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount =>
      _notifications.where((notification) => notification.isUnread).length;

  Future<void> loadNotifications() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _api.fetchNotifications();
      _notifications
        ..clear()
        ..addAll(results);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('Failed to load notifications: $error');
        print(stackTrace);
      }
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> refreshNotifications() async {
    _initialized = false;
    await loadNotifications();
  }

  Future<void> markNotificationAsRead(AppNotification notification) async {
    if (notification.isRead) return;

    final index = _notifications.indexWhere((item) => item.id == notification.id);
    if (index == -1) return;

    _notifications[index] = notification.copyWith(isRead: true);
    notifyListeners();

    try {
      final updated = await _api.markAsRead(notification.id);
      _notifications[index] = notification.copyWith(
        title: updated.title.isNotEmpty ? updated.title : null,
        message: updated.message.isNotEmpty ? updated.message : null,
        isRead: updated.isRead,
        createdAt: updated.createdAt ?? notification.createdAt,
      );
      notifyListeners();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('Failed to mark notification as read: $error');
        print(stackTrace);
      }
      _notifications[index] = notification;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    final unread =
        _notifications.where((notification) => notification.isUnread).toList();
    if (unread.isEmpty) return;

    for (final notification in unread) {
      await markNotificationAsRead(notification);
    }
  }
}
