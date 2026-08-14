import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:premium_engneering_app/core/network/api_client.dart';
import 'package:premium_engneering_app/core/network/api_response.dart';
import 'package:premium_engneering_app/features/home/model/dealer_type_model.dart';
import 'package:premium_engneering_app/features/home/model/home_model.dart';
import 'package:premium_engneering_app/features/home/model/vehicle_format_model.dart';
import 'package:premium_engneering_app/features/home/model/cylinder_make_model.dart';
import 'package:premium_engneering_app/features/home/model/role1_certificate_list_model.dart';
import 'package:premium_engneering_app/features/home/model/vehicle_type_model.dart';
import 'package:premium_engneering_app/features/home/model/payment_master_model.dart';
import 'package:premium_engneering_app/features/home/model/payment_transaction_model.dart';
import 'package:premium_engneering_app/core/storage/local_storage.dart';

class HomeRepository {
  final ApiClient apiClient;

  HomeRepository(this.apiClient);

  Future<CylinderMakeModel> getCylinderMakeRepo() async {
    try {
      final response = await apiClient.get("get_cylinder_make.php");
      return CylinderMakeModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to fetch cylinder make");
    }
  }

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// ================= GET HOME DATA =================

  Future<HomeModel> homeRepo() async {
    try {
      final response = await apiClient.get("get_product_name.php");
      final responseData = response.data;
      return HomeModel.fromJson(responseData);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to load home data");
    }
  }

  /// ================= GET PRODUCT STANDARD NAME =================
  Future<dynamic> getProductStandardNameRepo(String productId) async {
    try {
      final formData = FormData.fromMap({'product_id': productId});
      final response = await apiClient.multipartPost(
        "get_product_standard_name.php",
        formData: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data ?? "Failed to fetch product standard name",
      );
    }
  }

  /// ================= CREATE CERTIFICATE =================

  Future<dynamic> createCertificateRepo(Map<String, dynamic> data) async {
    try {
      final formData = FormData.fromMap(data);
      final response = await apiClient.multipartPost(
        "select_gas_process_selection.php",
        formData: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to create certificate");
    }
  }

  /// ================= SAVE CERTIFICATE ROLE 1 =================
  Future<dynamic> saveCertificateRole1(Map<String, dynamic> data) async {
    try {
      final String? filePath = data['photo_path'];
      data.remove('photo_path'); // Remove the path from standard fields

      // Create FormData from the rest of the data
      final formData = FormData.fromMap(data);

      // Add file if exists
      if (filePath != null && filePath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'photo_number_plate',
            await MultipartFile.fromFile(
              filePath,
              filename: filePath.split('/').last,
            ),
          ),
        );
      }

      final response = await apiClient.multipartPost(
        "r_cetificate_save.php",
        formData: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to save certificate");
    }
  }

  /// ================= GET VEHICLE TYPE =================

  Future<VehicleTypeModel> getVehicleTypeRepo(
    String dealerId,
    String productId,
  ) async {
    try {
      dynamic requestData = {'dealer_id': dealerId, 'product_id': productId};
      final formData = FormData.fromMap(requestData);
      print('requestData---------.$requestData');
      final response = await apiClient.multipartPost(
        "getvehicle_type.php",
        formData: formData,
      );
      final responseData = response.data;
      return VehicleTypeModel.fromJson(responseData);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to fetch vehicle types");
    }
  }

  Future<DelearTypeModel> getDealerTypeRepo(Map<String, dynamic> data) async {
    try {
      final formData = FormData.fromMap(data);
      final response = await apiClient.multipartPost(
        "getdealer.php",
        formData: formData,
      );
      final responseData = response.data;
      return DelearTypeModel.fromJson(responseData);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to fetch dealers");
    }
  }

  Future<VehicleFormatModel> getVehicleFormatRepo() async {
    try {
      final response = await apiClient.get("getvehicle_format.php");
      final responseData = response.data;
      return VehicleFormatModel.fromJson(responseData);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to fetch vehicle formats");
    }
  }

  /// ================= CHECK VEHICLE NO =================
  Future<dynamic> checkVehicleNoRepo(Map<String, dynamic> data) async {
    try {
      final formData = FormData.fromMap(data);
      final response = await apiClient.multipartPost(
        "checkvehicle_no.php",
        formData: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to check vehicle number");
    }
  }

  /// ================= GET PRODUCT AMOUNT BY DEALER =================
  Future<dynamic> getProductAmountByDealerRepo(
    Map<String, dynamic> data,
  ) async {
    try {
      final formData = FormData.fromMap(data);
      final response = await apiClient.multipartPost(
        "get_product_amount_by_dealer.php",
        formData: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to fetch product amount");
    }
  }

  /// ================= SAVE TOKEN =================
  Future<void> saveToken(String token) async {
    await _storage.write(key: "auth_token", value: token);
  }

  /// ================= GET TOKEN =================
  Future<String?> getToken() async {
    return await _storage.read(key: "auth_token");
  }

  /// ================= CLEAR TOKEN =================
  Future<void> clearToken() async {
    await _storage.delete(key: "auth_token");
  }

  /// ================= GET CERTIFICATE LIST (ROLE 1) =================
  Future<Role1CertificateListModel> getCertificateListRole1(
    String userId,
  ) async {
    print('UserID-------------${userId}');
    try {
      final formData = FormData.fromMap({'user_id': userId});
      final response = await apiClient.multipartPost(
        "role_1_getcertificate_list.php",
        formData: formData,
      );
      final responseData = response.data;
      return Role1CertificateListModel.fromJson(responseData);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to fetch certificate list");
    }
  }

  Future<Role1CertificateListModel> getCertificateListRole2(
    String adminId,
  ) async {
    try {
      print('ADMIN ID sent to certificate list API ---------> $adminId');
      final formData = FormData.fromMap({'admin_id': adminId});
      final response = await apiClient.multipartPost(
        "getcertificate_list.php",
        formData: formData,
      );
      final responseData = response.data;

      return Role1CertificateListModel.fromJson(responseData);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to fetch certificate list");
    }
  }

  Future<ApiResponse> updateCertificateRole1(Map<String, dynamic> data) async {
    try {
      final String? photoPath = data.remove('photo_path');
      // 2. Remove any null values to keep metadata clean
      data.removeWhere((key, value) => value == null);

      final formData = FormData.fromMap(data);
      // 3. Add file if exists
      if (photoPath != null && photoPath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'photo_number_plate',
            await MultipartFile.fromFile(
              photoPath,
              filename: photoPath.split('/').last,
            ),
          ),
        );
      }

      final response = await apiClient.multipartPost(
        "role1_update_cetificate.php",
        formData: formData,
      );

      if (response.data is String) {
        final dataStr = response.data as String;
        // If it's a non-empty string and doesn't look like HTML error, assume success (likely a record ID)
        if (dataStr.trim().isNotEmpty &&
            !dataStr.contains('<!DOCTYPE html>') &&
            !dataStr.contains('Error')) {
          return ApiResponse(
            success: true,
            message: "Update successful",
            data: dataStr,
          );
        }
        return ApiResponse(
          success: false,
          message: "Server returned unexpected response: $dataStr",
        );
      }

      return ApiResponse.fromJson(response.data);
    } catch (e) {
      throw Exception("Update failed: $e");
    }
  }

  Future<ApiResponse> updateCertificateRole2(Map<String, dynamic> data) async {
    try {
      print("======= UPDATE CERTIFICATE ROLE 2 REQUEST DATA =======");
      print("Raw Data: $data");
      print("======================================================");

      final String? photoPathPlate = data.remove('photo_number_plate');
      final String? photoPathNeck = data.remove('photo_marking_details');
      data.removeWhere((key, value) => value == null);

      final formData = FormData.fromMap(data);

      if (photoPathPlate != null && photoPathPlate.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'photo_number_plate',
            await MultipartFile.fromFile(
              photoPathPlate,
              filename: photoPathPlate.split('/').last,
            ),
          ),
        );
      }

      if (photoPathNeck != null && photoPathNeck.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'photo_marking_details',
            await MultipartFile.fromFile(
              photoPathNeck,
              filename: photoPathNeck.split('/').last,
            ),
          ),
        );
      }

      print("======= UPDATE CERTIFICATE ROLE 2 FORMDATA =======");
      print("FormData Fields: ${formData.fields}");
      print("FormData Files length: ${formData.files.length}");
      print(
        "FormData Files: ${formData.files.map((e) => '${e.key}: ${e.value.filename}').toList()}",
      );
      print("==================================================");

      final response = await apiClient.multipartPost(
        "update_certificate.php",
        formData: formData,
      );

      if (response.data is String) {
        final dataStr = response.data as String;
        if (dataStr.contains('success')) {
          return ApiResponse(
            success: true,
            message: "Update successful",
            data: dataStr,
          );
        }
        return ApiResponse(success: false, message: dataStr);
      }

      return ApiResponse.fromJson(response.data);
    } catch (e) {
      throw Exception("Update failed: $e");
    }
  }

  /// ================= SAVE REJECTED CYLINDER =================
  Future<ApiResponse> saveRejectedCylinder(Map<String, dynamic> data) async {
    try {
      final String? filePath = data['rcp'];
      data.remove('rcp');

      final formData = FormData.fromMap(data);

      if (filePath != null && filePath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'rcp',
            await MultipartFile.fromFile(
              filePath,
              filename: filePath.split('/').last,
            ),
          ),
        );
      }

      final response = await apiClient.multipartPost(
        "rejected_cylinder.php",
        formData: formData,
      );
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to save rejected cylinder");
    }
  }

  /// ================= SAVE CERTIFICATE ROLE 2 =================
  Future<ApiResponse> saveCertificateRole2(Map<String, dynamic> data) async {
    try {
      // 1. Extract file paths
      final String? photoPathPlate = data.remove('photo_path_plate');
      final String? photoPathNeck = data.remove('photo_path_neck');

      final formData = FormData.fromMap(data);

      // 2. Add files if exist
      if (photoPathPlate != null && photoPathPlate.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'pnp',
            await MultipartFile.fromFile(
              photoPathPlate,
              filename: photoPathPlate.split('/').last,
            ),
          ),
        );
      }
      if (photoPathNeck != null && photoPathNeck.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'pmd',
            await MultipartFile.fromFile(
              photoPathNeck,
              filename: photoPathNeck.split('/').last,
            ),
          ),
        );
      }

      final response = await apiClient.multipartPost(
        "certificate_save.php",
        formData: formData,
      );

      print("📦 SAVING DATA TYPE: ${response.data.runtimeType}");
      if (response.data is String) {
        final dataStr = response.data as String;
        if (dataStr.contains('success') ||
            dataStr.toLowerCase().contains('saved')) {
          return ApiResponse(
            success: true,
            message: "Certificate saved successfully",
            data: dataStr,
          );
        }
        // If 200 and data is empty, some APIs assume success
        if (dataStr.isEmpty) {
          return ApiResponse(
            success: true,
            message: "Certificate saved successfully",
          );
        }
        return ApiResponse(success: false, message: dataStr);
      }

      return ApiResponse.fromJson(response.data);
    } catch (e) {
      throw Exception("Save failed: $e");
    }
  }

  Future<Map<String, dynamic>> getDealerAmountRepo(
    String dealerId, {
    String? certId,
  }) async {
    try {
      final localStorage = LocalStorage();
      final adminId = await localStorage.getAdminId();

      final formData = FormData.fromMap({
        'dealer_id': dealerId,
        if (certId != null) 'id': certId,
      });
      final response = await apiClient.multipartPost(
        "get_dealer_amount.php",
        formData: formData,
        options: Options(headers: {'admin_id': adminId}),
      );
      return response.data;
    } catch (e) {
      throw Exception("Failed to fetch dealer amount: $e");
    }
  }

  Future<PaymentMasterModel> getPaymentMaster() async {
    try {
      final localStorage = LocalStorage();
      final adminId = await localStorage.getAdminId();
      final token = await localStorage.getToken();

      final response = await apiClient.get(
        "getPaymentmaster.php",
        options: Options(
          headers: {'admin_id': adminId, 'Authorization': 'Bearer $token'},
        ),
      );
      return PaymentMasterModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to fetch payment master");
    }
  }

  Future<PaymentTransactionModel> getTransactionHistory(String certId) async {
    try {
      final localStorage = LocalStorage();
      final adminId = await localStorage.getAdminId();
      final token = await localStorage.getToken();

      final formData = FormData.fromMap({'id': certId});
      final response = await apiClient.multipartPost(
        "get_payment_trans.php",
        formData: formData,
        options: Options(
          headers: {'admin_id': adminId, 'Authorization': 'Bearer $token'},
        ),
      );
      return PaymentTransactionModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data ?? "Failed to fetch transaction history",
      );
    }
  }

  Future<bool> savePaymentRole1(Map<String, dynamic> paymentData) async {
    try {
      final localStorage = LocalStorage();
      final adminId = await localStorage.getAdminId();
      final token = await localStorage.getToken();

      final formData = FormData.fromMap(paymentData);
      final response = await apiClient.multipartPost(
        "role1_savepayment.php",
        formData: formData,
        options: Options(
          headers: {'admin_id': adminId, 'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data is Map) {
        return response.data['status'] == 'success' ||
            response.data['status'] == 'Success';
      }
      if (response.data is String) {
        return response.data.toLowerCase().contains('success');
      }
      return true;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to save payment");
    }
  }

  Future<bool> updatePrintStatus(String certificateId) async {
    try {
      final formData = FormData.fromMap({
        'c_id': certificateId,
        'certid': certificateId,
        'print_status': '3',
      });
      final response = await apiClient.multipartPost(
        "print_status.php",
        formData: formData,
      );
      print("formData.data: ${formData}");
      if (response.data is Map) {
        return response.data['status'] == 'success' ||
            response.data['status'] == 'Success';
      }
      return response.data.toString().toLowerCase().contains('success');
    } catch (e) {
      print("Error updating print status: $e");
      return false;
    }
  }

  /// ================= CHECK LAST TESTING DATE =================
  Future<dynamic> checkLastTestingDateRepo(Map<String, dynamic> data) async {
    try {
      print("🚀 SENDING REQUEST: check_last_testing_date.php | DATA: $data");
      final formData = FormData.fromMap(data);
      final response = await apiClient.multipartPost(
        "check_last_testing_date.php",
        formData: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to check last testing date");
    }
  }
}
