import 'dart:convert';

import 'package:booking_group_flutter/core/constants/api_constants.dart';
import 'package:booking_group_flutter/core/services/api_service.dart';
import 'package:booking_group_flutter/models/my_group.dart';

class SemestersApi {
  SemestersApi({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<Semester?> fetchActiveSemester() async {
    final response = await _apiService.get(
      '${ApiConstants.apiVersion}${ApiConstants.semesters}',
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load semesters (${response.statusCode})');
    }

    final Map<String, dynamic> jsonResponse =
        jsonDecode(response.body) as Map<String, dynamic>;
    final dynamic data = jsonResponse['data'];

    Iterable<Map<String, dynamic>> items = const <Map<String, dynamic>>[];

    if (data is List) {
      items = data.whereType<Map<String, dynamic>>();
    } else if (data is Map<String, dynamic>) {
      final content = data['content'];
      if (content is List) {
        items = content.whereType<Map<String, dynamic>>();
      }
    }

    for (final item in items) {
      final isActive = item['active'] == true;
      if (isActive) {
        return Semester.fromJson(item);
      }
    }

    if (items.isNotEmpty) {
      return Semester.fromJson(items.first);
    }

    return null;
  }
}
