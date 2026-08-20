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

          /// ✅ ADD BEARER TOKEN (Except for login)
          if (token != null && token.isNotEmpty && !options.path.contains("login.php")) {
            options.headers["Authorization"] = "Bearer $token";
          }

          print("╔═════════════════════════ REQUEST ═════════════════════════");
          print("║ URL: ${options.method} ${options.baseUrl}${options.path}");
          print("║ HEADERS: ${_prettyPrint(options.headers)}");
          
          if (options.data is FormData) {
            final fd = options.data as FormData;
            print("║ BODY (FormData): Fields: ${fd.fields.map((e) => '${e.key}: ${e.value}')} Files: ${fd.files.map((e) => e.key)}");
          } else {
            print("║ BODY: ${_prettyPrint(options.data)}");
          }
          print("╚═══════════════════════════════════════════════════════════");

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Automatically decode JSON if possible
          if (response.data is String && (response.data as String).trim().startsWith('{')) {
            try {
              response.data = jsonDecode(response.data);
            } catch (e) {
              // ignore
            }
          }

          print("╔════════════════════════ RESPONSE ═════════════════════════");
          print("║ URL: ${response.requestOptions.path}");
          print("║ STATUS: ${response.statusCode}");
          print("║ DATA:\n${_prettyPrint(response.data)}");
          print("╚═══════════════════════════════════════════════════════════");

          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print("╔═════════════════════════ ERROR ═══════════════════════════");
          print("║ URL: ${e.requestOptions.path}");
          print("║ TYPE: ${e.type}");
          print("║ MESSAGE: ${e.message}");
          print("║ RESPONSE:\n${_prettyPrint(e.response?.data)}");
          print("╚═══════════════════════════════════════════════════════════");
          return handler.next(e);
        },
      ),
    );
  }

  String _prettyPrint(dynamic data) {
    if (data == null) return "null";
    if (data is Map || data is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(data).split('\n').map((l) => '║ $l').join('\n');
      } catch (_) {
        return data.toString();
      }
    } else if (data is String) {
      try {
        final decoded = jsonDecode(data);
        return const JsonEncoder.withIndent('  ').convert(decoded).split('\n').map((l) => '║ $l').join('\n');
      } catch (_) {
        return data;
      }
    }
    return data.toString();
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
