import 'dart:convert';

import 'package:booking_group_flutter/core/network/api_exception.dart';
import 'package:booking_group_flutter/core/storage/session_storage.dart';
import 'package:http/http.dart' as http;

class BackendClient {
  BackendClient({
    required SessionStorage storage,
    http.Client? httpClient,
  })  : _storage = storage,
        _http = httpClient ?? http.Client();

  static const String baseUrl =
      'https://swd392-exe-team-management-be.onrender.com/api';

  final SessionStorage _storage;
  final http.Client _http;

  Future<BackendResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) {
    return _send(
      'GET',
      path,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
    );
  }

  Future<BackendResponse> post(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) {
    return _send(
      'POST',
      path,
      body: body,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
    );
  }

  Future<BackendResponse> put(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) {
    return _send(
      'PUT',
      path,
      body: body,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
    );
  }

  Future<BackendResponse> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) {
    return _send(
      'DELETE',
      path,
      body: body,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
    );
  }

  Future<BackendResponse> _send(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _storage.readToken();
      if (token == null || token.isEmpty) {
        throw const MissingSessionException();
      }
      headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await _http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await _http.post(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await _http.put(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await _http.delete(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          );
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }
    } catch (error) {
      throw ApiException('Failed to connect to server', details: error);
    }

    return _parseResponse(response);
  }

  BackendResponse _parseResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (error) {
      throw ApiException('Unable to parse server response', details: error);
    }

    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('Unexpected response structure from server');
    }

    final status = decoded['status'] as int? ?? response.statusCode;
    final message = decoded['message'] as String?;
    final data = decoded['data'];

    if (response.statusCode >= 400 || status >= 400) {
      throw ApiException(
        message ?? 'Request failed',
        statusCode: response.statusCode,
        backendStatus: status,
        details: data,
      );
    }

    return BackendResponse(
      status: status,
      message: message,
      data: data,
    );
  }
}

class BackendResponse {
  const BackendResponse({
    required this.status,
    this.message,
    this.data,
  });

  final int status;
  final String? message;
  final dynamic data;

  T mapData<T>(T Function(dynamic data) mapper) {
    return mapper(data);
  }
}
