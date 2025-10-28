import 'package:booking_group_flutter/core/network/backend_client.dart';
import 'package:booking_group_flutter/features/user/domain/user_profile.dart';

class UserRepository {
  const UserRepository({required BackendClient client}) : _client = client;

  final BackendClient _client;

  Future<UserProfile> fetchMyProfile() async {
    final response = await _client.get('/users/myInfo');
    final data = (response.data ?? {}) as Map<String, dynamic>?;
    if (data == null) {
      throw const FormatException('Unexpected empty user profile response');
    }
    return UserProfile.fromJson(data);
  }
}
