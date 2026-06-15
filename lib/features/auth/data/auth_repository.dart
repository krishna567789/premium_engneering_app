import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/local_storage.dart';

class AuthRepository {
  final ApiClient apiClient;
  final LocalStorage _storage = LocalStorage();

  AuthRepository(this.apiClient);

  /// ================= LOGIN =================
  Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final deviceId = await _storage.getDeviceId();

      print('---------------------DeviceId-----------------> $deviceId');

      final formData = FormData.fromMap({
        "username": email,
        "password": password,
        "deviced_id": deviceId,
      });

      final response = await apiClient.post("login.php", data: formData);
      if (response.statusCode == 200) {}
      final responseData = response.data as Map<String, dynamic>;

      // ⚡ PARSE FIRST — before touching storage so we never crash on 403
      final apiResponse = ApiResponse.fromJson(responseData);

      print('📦 RAW STATUS     : ${responseData['status']}');
      print('📦 parsedStatus   : ${apiResponse.statusCode}');
      print('📦 success        : ${apiResponse.success}');
      print('📦 message        : ${apiResponse.message}');

      // 🔴 Early return for 403 / any non-success — nothing to save
      if (!apiResponse.success) {
        return apiResponse;
      }

      // ✅ Only runs on real login success
      final token = responseData['access_token'];
      final userType = responseData['user_type'];

      await _storage.saveToken(token);
      await _storage.saveUserType(userType);

      print('TOKEN ------------------> $token');
      print('USER TYPE -------------> $userType');

      /// ================= JWT DECODE =================
      try {
        print('TOKEN RAW -----------> $token');

        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

        print('DECODED TOKEN ----------> $decodedToken');

        final adminId = decodedToken['data']['admin_id'];
        final userId = decodedToken['data']['id'];
        final userName = decodedToken['data']['user_name'];

        print('ADMIN ID --------------> $adminId');
        print('USER ID ---------------> $userId');
        print('USER NAME -------------> $userName');

        if (adminId != null) {
          await _storage.saveAdminId(adminId.toString());
        }
        if (userId != null) {
          await _storage.saveUserId(userId.toString());
        }
        if (userName != null) {
          await _storage.saveUserName(userName.toString());
        }
      } catch (e) {
        print('❌ Token decode error: $e');
      }

      return apiResponse;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Login failed");
    }
  }

  /// ================= TOKEN & USER TYPE =================
  Future<void> saveToken(String token) async => await _storage.saveToken(token);

  Future<String?> getToken() async => await _storage.getToken();

  Future<void> saveUserType(String type) async =>
      await _storage.saveUserType(type);

  Future<String?> getUserType() async => await _storage.getUserType();

  Future<void> saveUserId(String id) async => await _storage.saveUserId(id);

  Future<String?> getUserId() async => await _storage.getUserId();

  Future<String?> getUserName() async => await _storage.getUserName();

  Future<void> saveAdminId(String id) async => await _storage.saveAdminId(id);

  Future<String?> getAdminId() async => await _storage.getAdminId();

  /// ================= LOGOUT =================
  Future<ApiResponse> logout() async {
    try {
      final response = await apiClient.post("logout.php");

      await _storage.clearAll();

      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      await _storage.clearAll();
      throw Exception(e.response?.data ?? "Logout failed");
    }
  }

  /// ================= CLEAR STORAGE =================
  Future<void> clearToken() async {
    await _storage.clearAll();
  }
}
