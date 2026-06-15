class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? accessToken;

  /// Raw status code from the API JSON body (e.g. 200, 403)
  final int? statusCode;

  /// In some error responses the API returns a username field
  final String? username;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.accessToken,
    this.statusCode,
    this.username,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    final int? parsedStatus =
        rawStatus is int ? rawStatus : int.tryParse(rawStatus?.toString() ?? '');

    return ApiResponse(
      /// ✅ FIX HERE
      success: parsedStatus == 200 || rawStatus == "success",

      message: json['message'] ?? '',

      /// ✅ your API has no "data"
      data: json['data'],

      /// ✅ GET TOKEN
      accessToken: json['access_token'],

      /// ✅ raw status for 403-style errors
      statusCode: parsedStatus,

      /// ✅ username returned on conflict
      username: json['username'],
    );
  }
}

