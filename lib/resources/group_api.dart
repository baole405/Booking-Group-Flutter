import 'dart:convert';

import 'package:booking_group_flutter/models/group.dart';
import 'package:http/http.dart' as http;

class GroupApi {
  const GroupApi();

  static const String _baseUrl =
      'https://swd392-exe-team-management-be.onrender.com/api';

  Future<List<Group>> fetchGroups({int page = 1, int size = 10}) async {
    final queryParameters = <String, String>{
      'page': '$page',
      'size': '$size',
    };
    final uri = Uri.parse('$_baseUrl/groups').replace(queryParameters: queryParameters);

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load groups (status: ${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      final content = data['content'];
      if (content is List) {
        return content
            .map(
              (raw) => Group.fromJson(
                Map<String, dynamic>.from(raw as Map),
              ),
            )
            .toList();
      }
    }
    return const [];
  }
}
