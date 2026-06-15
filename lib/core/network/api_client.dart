import 'dart:convert';
import 'package:dio/dio.dart';
import '../storage/local_storage.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio) {
    dio.options = BaseOptions(
      baseUrl: "https://pe.microcmd.com/API/",
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      responseType: ResponseType.plain,
      headers: {
        'User-Agent': 'PremiumEngineeringApp/1.0 (Dart/Dio)',
        'Accept': 'application/json',
      },
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final storage = LocalStorage();

          // Set content type for standard Map data
          if (options.data is Map && options.headers['Content-Type'] == null) {
            options.contentType = "application/x-www-form-urlencoded";
          }

          /// ✅ GET TOKEN (from storage)
          final token = await storage.getToken();
          print("🔑 DEBUG: TOKEN RETRIEVED: ${token != null ? 'YES' : 'NO'}");

          /// ✅ ADD BEARER TOKEN (Except for login)
          if (token != null && token.isNotEmpty && !options.path.contains("login.php")) {
            options.headers["Authorization"] = "Bearer $token";
          }
          print("➡️ REQUEST");
          print("URL: ${options.baseUrl}${options.path}");
          print("METHOD: ${options.method}");
          print("HEADERS: ${options.headers}");
          print("CONTENT-TYPE: ${options.contentType}");
          print("BODY: ${options.data}");

          return handler.next(options);
        },

        onResponse: (response, handler) {
          print("✅ RESPONSE");
          print("URL: ${response.requestOptions.path}");
          print("STATUS: ${response.statusCode}");
          print("DATA: ${response.data}");

          // Automatically decode JSON if possible
          if (response.data is String && (response.data as String).trim().startsWith('{')) {
            try {
              response.data = jsonDecode(response.data);
            } catch (e) {
              print("⚠️ DEBUG: Failed to decode JSON response: $e");
            }
          }

          return handler.next(response);
        },

        onError: (DioException e, handler) {
          print("❌ ERROR");
          print("TYPE: ${e.type}");
          print("ERROR: ${e.error}");
          print("URL: ${e.requestOptions.path}");
          print("MESSAGE: ${e.message}");
          print("RESPONSE: ${e.response?.data}");
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String url, {Options? options}) async {
    return await dio.get(url, options: options);
  }

  Future<Response> post(String url, {dynamic data, Options? options}) async {
    return await dio.post(url, data: data, options: options);
  }

  Future<Response> multipartPost(
    String url, {
    required FormData formData,
    Options? options,
    Function(int, int)? onSendProgress,
  }) async {
    return await dio.post(
      url,
      data: formData,
      options: options,
      onSendProgress: onSendProgress,
    );
  }
}
