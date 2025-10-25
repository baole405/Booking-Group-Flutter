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
