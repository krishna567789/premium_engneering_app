import 'package:dio/dio.dart';

class DioExceptions {
  static String getError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection timeout";
      case DioExceptionType.receiveTimeout:
        return "Server timeout";
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        if (data is Map) {
          return data['message'] ?? "Server error";
        }
        return data?.toString() ?? "Server error";
      default:
        return "Something went wrong";
    }
  }
}
