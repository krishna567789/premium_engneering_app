import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Keys
  static const String _tokenKey = "auth_token";
  static const String _userTypeKey = "user_type";
  static const String _userIdKey = "user_id";
  static const String _adminIdKey = "admin_id";
  static const String _deviceIdKey = "device_id";
  static const String _userNameKey = "user_name";

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveUserType(String userType) async {
    await _storage.write(key: _userTypeKey, value: userType);
  }

  Future<String?> getUserType() async {
    return await _storage.read(key: _userTypeKey);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<void> saveAdminId(String adminId) async {
    await _storage.write(key: _adminIdKey, value: adminId);
  }

  Future<String?> getAdminId() async {
    return await _storage.read(key: _adminIdKey);
  }

  Future<String> getDeviceId() async {
    String? deviceId = await _storage.read(key: _deviceIdKey);
    if (deviceId == null) {
      // Generate a simple unique ID using timestamp
      deviceId = "DEVICE_${DateTime.now().millisecondsSinceEpoch}";
      await _storage.write(key: _deviceIdKey, value: deviceId);
    }
    return deviceId;
  }

  Future<void> saveUserName(String name) async {
    await _storage.write(key: _userNameKey, value: name);
  }

  Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
