import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStorage {
  const SessionStorage()
      : _secureStorage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  static const _tokenKey = 'auth_token';
  static const _emailKey = 'auth_email';

  final FlutterSecureStorage _secureStorage;

  Future<void> saveSession({required String token, required String email}) async {
    await Future.wait([
      _secureStorage.write(key: _tokenKey, value: token),
      _secureStorage.write(key: _emailKey, value: email),
    ]);
  }

  Future<String?> readToken() => _secureStorage.read(key: _tokenKey);

  Future<String?> readEmail() => _secureStorage.read(key: _emailKey);

  Future<void> clear() async {
    await Future.wait([
      _secureStorage.delete(key: _tokenKey),
      _secureStorage.delete(key: _emailKey),
    ]);
  }

  @visibleForTesting
  Future<void> writeToken(String? token) =>
      _secureStorage.write(key: _tokenKey, value: token);
}
