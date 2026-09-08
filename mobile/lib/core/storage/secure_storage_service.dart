import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _employeeIdKey = 'employee_id';
  static const _userNameKey = 'user_name';
  static const _userRoleKey = 'user_role';

  // ─── Token Management ────────────────────────────────────────────────────

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  static Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);
  static Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  static Future<void> saveUserInfo({
    required String userId,
    required String employeeId,
    required String name,
    required String role,
  }) async {
    await Future.wait([
      _storage.write(key: _userIdKey, value: userId),
      _storage.write(key: _employeeIdKey, value: employeeId),
      _storage.write(key: _userNameKey, value: name),
      _storage.write(key: _userRoleKey, value: role),
    ]);
  }

  static Future<Map<String, String?>> getUserInfo() async {
    final results = await Future.wait([
      _storage.read(key: _userIdKey),
      _storage.read(key: _employeeIdKey),
      _storage.read(key: _userNameKey),
      _storage.read(key: _userRoleKey),
    ]);
    return {
      'userId': results[0],
      'employeeId': results[1],
      'name': results[2],
      'role': results[3],
    };
  }

  static Future<bool> hasValidSession() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearAll() => _storage.deleteAll();
}
