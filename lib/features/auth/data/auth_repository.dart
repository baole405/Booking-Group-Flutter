import 'package:booking_group_flutter/core/network/backend_client.dart';
import 'package:booking_group_flutter/features/auth/data/models/auth_session.dart';

class AuthRepository {
  const AuthRepository({required BackendClient client}) : _client = client;

  final BackendClient _client;

  Future<AuthSession> loginWithGoogle(String idToken) async {
    final response = await _client.post(
      '/auth/google-login',
      requiresAuth: false,
      body: {'idToken': idToken},
    );

    final payload = (response.data ?? {}) as Map<String, dynamic>?;
    final email = payload?['email'] as String?;
    final token = payload?['token'] as String?;

    if (email == null || token == null) {
      throw const FormatException('Missing credentials from login response');
    }

    return AuthSession(email: email, token: token);
  }
}
