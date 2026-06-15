// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:premium_engneering_app/core/network/api_client.dart';
// import 'package:premium_engneering_app/core/network/api_response.dart';
// import 'package:premium_engneering_app/core/network/dio_exceptions.dart';

// class UploadService {
//   final ApiClient apiClient;

//   UploadService(this.apiClient);

//   Future<ApiResponse> upload({
//     required String url,
//     required List<File> files,
//     required Map<String, String> params,
//     required Function(int) onProgress,
//   }) async {
//     try {
//       FormData formData = FormData();

//       // files
//       for (var file in files) {
//         var mime = lookupMimeType(file.path) ?? "application/octet-stream";
//         var type = mime.split("/");

//         var multipart = await MultipartFile.fromFile(
//           file.path,
//           filename: file.path.split('/').last,
//           contentType: MediaType(type[0], type[1]),
//         );

//         if (type[0] == 'video') {
//           formData.files.add(MapEntry("videos", multipart));
//         } else {
//           formData.files.add(MapEntry("images", multipart));
//         }
//       }

//       // params
//       params.forEach((k, v) {
//         formData.fields.add(MapEntry(k, v));
//       });

//       final response = await apiClient.multipartPost(
//         url,
//         formData: formData,
//         onSendProgress: (c, t) {
//           int progress = ((c / t) * 100).toInt();
//           onProgress(progress);
//         },
//       );

//       return ApiResponse.fromJson(response.data);

//     } on DioException catch (e) {
//       throw Exception(DioExceptions.getError(e));
//     }
//   }
// }
