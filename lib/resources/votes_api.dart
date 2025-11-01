import 'dart:convert';

import 'package:booking_group_flutter/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VotesApi {
  VotesApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('bearerToken');
  }

  Map<String, String> _headers(String token) => ApiConstants.authHeaders(token);

  Map<String, dynamic> _decode(String body) {
    if (body.isEmpty) return const {};
    return jsonDecode(body) as Map<String, dynamic>;
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final content = data['content'];
      if (content is List) return content;
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> getGroupVotes(int groupId) async {
    final token = await _token();
    if (token == null) {
      throw Exception('Missing authentication token');
    }

    final response = await _client.get(
      Uri.parse(ApiConstants.getGroupVotesUrl(groupId)),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load votes (${response.statusCode})');
    }

    final decoded = _decode(response.body);
    return _extractList(
      decoded['data'],
    ).whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>> getVoteDetail(int voteId) async {
    final token = await _token();
    if (token == null) {
      throw Exception('Missing authentication token');
    }

    final response = await _client.get(
      Uri.parse(ApiConstants.getVoteDetailUrl(voteId)),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load vote (${response.statusCode})');
    }

    final decoded = _decode(response.body);
    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }

    throw Exception('Vote data is unavailable');
  }

  Future<List<Map<String, dynamic>>> getVoteChoices(int voteId) async {
    final token = await _token();
    if (token == null) {
      throw Exception('Missing authentication token');
    }

    final response = await _client.get(
      Uri.parse(ApiConstants.getVoteChoicesUrl(voteId)),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load vote choices (${response.statusCode})');
    }

    final decoded = _decode(response.body);
    final list = _extractList(decoded['data']);
    return list.whereType<Map<String, dynamic>>().toList();
  }

  Future<void> submitChoice({
    required int voteId,
    required String choiceValue,
  }) async {
    final token = await _token();
    if (token == null) {
      throw Exception('Missing authentication token');
    }

    final response = await _client.post(
      Uri.parse(ApiConstants.voteChoiceUrl(voteId, choiceValue)),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit vote (${response.statusCode})');
    }
  }

  Future<void> finalizeVote(int voteId) async {
    final token = await _token();
    if (token == null) {
      throw Exception('Missing authentication token');
    }

    final response = await _client.patch(
      Uri.parse(ApiConstants.finalizeVoteUrl(voteId)),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to finalize vote (${response.statusCode})');
    }
  }
}
