import 'package:booking_group_flutter/models/invite.dart';

/// API Constants - Centralized configuration for all API endpoints
class ApiConstants {
  // Base URL
  static const String baseUrl =
      'https://swd392-exe-team-management-be.onrender.com';

  // API Version
  static const String apiVersion = '/api';

  // Full Base API URL
  static String get baseApiUrl => '$baseUrl$apiVersion';

  // Auth Endpoints
  static const String googleLogin = '/auth/google-login';
  static String get googleLoginUrl => '$baseApiUrl$googleLogin';

  // User Endpoints
  static const String myInfo = '/users/myInfo';
  static String get myInfoUrl => '$baseApiUrl$myInfo';
  static String get updateMyInfoUrl => '$baseApiUrl$myInfo';

  // Group Endpoints
  static const String groups = '/groups';
  static String get groupsUrl => '$baseApiUrl$groups';

  static const String myGroup = '/groups/my-group';
  static String get myGroupUrl => '$baseApiUrl$myGroup';

  static const String updateGroup = '/groups/update';
  static String get updateGroupUrl => '$baseApiUrl$updateGroup';

  static const String changeGroupType = '/groups/change-type';
  static String get changeGroupTypeUrl => '$baseApiUrl$changeGroupType';

  static const String completeGroup = '/groups/done';
  static String get completeGroupUrl => '$baseApiUrl$completeGroup';

  // Invite Endpoints
  static const String invites = '/invites';
  static String get invitesUrl => '$baseApiUrl$invites';

  static String getMyInvitesUrl({
    InviteStatus? status,
    int receivedPage = 1,
    int receivedSize = 10,
    int sentPage = 1,
    int sentSize = 10,
  }) {
    final queryParameters = <String, String>{
      'receivedPage': '$receivedPage',
      'receivedSize': '$receivedSize',
      'sentPage': '$sentPage',
      'sentSize': '$sentSize',
    };

    if (status != null) {
      queryParameters['status'] = status.name.toUpperCase();
    }

    final query = queryParameters.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');

    return '$baseApiUrl$invites/my?$query';
  }

  static String updateInviteStatusUrl(int inviteId) {
    return '$baseApiUrl$invites/$inviteId';
  }

  // Comment Endpoints
  static const String comments = '/comments';
  static String get commentsUrl => '$baseApiUrl$comments';

  static String getPostCommentsUrl(int postId) {
    return '$baseApiUrl$comments/post/$postId';
  }

  // Notification Endpoints
  static const String notifications = '/notifications';
  static String get notificationsUrl => '$baseApiUrl$notifications';

  static String markNotificationAsReadUrl(int notificationId) {
    return '$baseApiUrl$notifications/$notificationId/read';
  }

  static String getGroupMembersUrl(int groupId) {
    return '$baseApiUrl$groups/$groupId/members';
  }

  static String getGroupLeaderUrl(int groupId) {
    return '$baseApiUrl$groups/$groupId/leader';
  }

  static String getGroupsWithPagination({int page = 1, int size = 20}) {
    return '$baseApiUrl$groups?page=$page&size=$size';
  }

  // Idea Endpoints
  static const String ideas = '/ideas';
  static String get ideasUrl => '$baseApiUrl$ideas';

  static String getGroupIdeasUrl(int groupId) {
    return '$baseApiUrl$ideas/group/$groupId';
  }

  static String getIdeaUrl(int ideaId) {
    return '$baseApiUrl$ideas/$ideaId';
  }

  static String getIdeasWithPagination({int page = 1, int size = 20}) {
    return '$baseApiUrl$ideas?page=$page&size=$size';
  }

  // Major Endpoints
  static const String majors = '/majors';
  static String get majorsUrl => '$baseApiUrl$majors';

  // Headers
  static Map<String, String> get jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
