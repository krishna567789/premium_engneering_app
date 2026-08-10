import 'package:flutter/material.dart';
import 'package:premium_engneering_app/features/auth/data/auth_repository.dart';
import 'package:premium_engneering_app/features/home/provider/home_state.dart';
import 'package:premium_engneering_app/features/home/data/home_repository.dart';
import 'package:premium_engneering_app/features/home/screens/role1_screen.dart';
import 'package:premium_engneering_app/features/home/screens/role2_screen.dart';
import 'package:provider/provider.dart';
import 'package:premium_engneering_app/features/home/model/home_model.dart';
import 'package:premium_engneering_app/features/home/model/dealer_type_model.dart'
    as dealer_model;
import '../../../widgets/custom_widgets.dart';

class HomeProvider extends ChangeNotifier {
  final HomeRepository repository;
  final AuthRepository authRepository;

  HomeProvider(this.repository, this.authRepository);

  HomeState _state = const HomeState();
  HomeState get state => _state;
  bool _isFormOpen = false;
  bool get isFormOpen => _isFormOpen;

  void setIsFormOpen(bool value) {
    _isFormOpen = value;
    notifyListeners();
  }

  void _setState(HomeState newState) {
    _state = newState;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _setState(state.copyWith(searchQuery: query));
  }

  void setSelectedProduct(Data? product) {
    _setState(state.copyWith(selectedProduct: product));
  }

  void setSelectedCylinderType(String? type) {
    _setState(state.copyWith(selectedCylinderType: type));
  }

  Future<void> loadHomeData() async {
    _setState(state.copyWith(status: HomeStatus.loading));
    try {
      final data = await repository.homeRepo();
      _setState(state.copyWith(status: HomeStatus.success, homeData: data));
    } catch (e) {
      _setState(
        state.copyWith(status: HomeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> createCertificate(
    Map<String, dynamic> certificateData,
    BuildContext context,
  ) async {
    _setState(state.copyWith(certificateStatus: HomeStatus.loading));
    try {
      final data = await repository.createCertificateRepo(certificateData);
      bool photoReq = true;
      if (data is Map) {
        final innerData = data['data'];
        final val = (innerData is Map)
            ? (innerData['photo_required'] ?? innerData['phtot_required'])
                  ?.toString()
                  .toLowerCase()
            : (data['photo_required'] ?? data['phtot_required'])
                  ?.toString()
                  .toLowerCase();

        if (val != null) {
          photoReq = val != 'no';
        }
      }

      dealer_model.DelearTypeModel? newDealerData;
      if (data is Map &&
          data.containsKey('dealer_amount_data') &&
          data['dealer_amount_data'] is List) {
        newDealerData = dealer_model.DelearTypeModel(
          status: data['status']?.toString(),
          data: List<dealer_model.Data>.from(
            (data['dealer_amount_data'] as List).map(
              (v) => dealer_model.Data.fromJson(v),
            ),
          ),
        );
      }

      _setState(
        state.copyWith(
          certificateStatus: HomeStatus.success,
          certificateResult: data,
          photoRequired: photoReq,
          dealerTypeData: newDealerData ?? state.dealerTypeData,
        ),
      );
      if (context.mounted) {
        final fetchedRole = await context.read<AuthRepository>().getUserType();
        if (fetchedRole == 'role_1') {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Role1Screen()),
          );
        } else if (fetchedRole == 'role_2') {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Role2Screen()),
          );
        }
      }

      setIsFormOpen(true);
    } catch (e) {
      _setState(
        state.copyWith(
          certificateStatus: HomeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<bool> submitRole1Certificate(
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    _setState(state.copyWith(certificateStatus: HomeStatus.loading));
    try {
      final response = await repository.saveCertificateRole1(data);
      _setState(
        state.copyWith(
          certificateStatus: HomeStatus.success,
          certificateResult: response,
        ),
      );
      clearDealerAmount();
      clearProductAmount();
      clearSelectedProductAndType();
      return true;
    } catch (e) {
      _setState(
        state.copyWith(
          certificateStatus: HomeStatus.error,
          errorMessage: e.toString(),
        ),
      );
      if (context.mounted) {
        CustomToast.error(context, "Error: $e", top: true);
      }
      return false;
    }
  }

  Future<void> getVehicleType(String dealerId, {String? productId}) async {
    _setState(state.copyWith(vehicleTypeStatus: HomeStatus.loading));
    try {
      final pId = productId ?? state.selectedProduct?.id?.toString() ?? '';
      final data = await repository.getVehicleTypeRepo(dealerId, pId);
      _setState(
        state.copyWith(
          vehicleTypeStatus: HomeStatus.success,
          vehicleTypeData: data,
        ),
      );
    } catch (e) {
      _setState(
        state.copyWith(
          vehicleTypeStatus: HomeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> getDealerType() async {
    _setState(state.copyWith(dealerTypeStatus: HomeStatus.loading));
    try {
      final adminId = await authRepository.getAdminId();
      final data = await repository.getDealerTypeRepo({
        'admin_id': adminId ?? '',
      });
      _setState(
        state.copyWith(
          dealerTypeStatus: HomeStatus.success,
          dealerTypeData: data,
        ),
      );
    } catch (e) {
      _setState(
        state.copyWith(
          dealerTypeStatus: HomeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> getCylinderMake() async {
    _setState(state.copyWith(cylinderMakeStatus: HomeStatus.loading));
    try {
      final data = await repository.getCylinderMakeRepo();
      _setState(
        state.copyWith(
          cylinderMakeStatus: HomeStatus.success,
          cylinderMakeData: data,
        ),
      );
    } catch (e) {
      _setState(
        state.copyWith(
          cylinderMakeStatus: HomeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> getDealerAmount(String dealerId, {String? certId}) async {
    _setState(state.copyWith(dealerAmountStatus: HomeStatus.loading));
    try {
      final response = await repository.getDealerAmountRepo(
        dealerId,
        certId: certId,
      );
      if (response['status'] == 'success') {
        _setState(
          state.copyWith(
            dealerAmountStatus: HomeStatus.success,
            dealerAmount: response['data']['amount'].toString(),
            dealerPendingAmount: response['data']['p_amount'].toString(),
            dealerPtStatus: response['data']['pt_status']?.toString(),
          ),
        );
      } else {
        _setState(
          state.copyWith(
            dealerAmountStatus: HomeStatus.error,
            errorMessage: response['message'] ?? "Failed to fetch amount",
          ),
        );
      }
    } catch (e) {
      _setState(
        state.copyWith(
          dealerAmountStatus: HomeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void clearDealerAmount() {
    _setState(
      state.copyWith(
        dealerAmount: null,
        dealerAmountStatus: HomeStatus.initial,
      ),
    );
  }

  Future<void> checkVehicleNumber(Map<String, dynamic> data) async {
    _setState(state.copyWith(vehicleCheckStatus: HomeStatus.loading));
    try {
      final response = await repository.checkVehicleNoRepo(data);
      _setState(
        state.copyWith(
          vehicleCheckStatus: HomeStatus.success,
          vehicleCheckData: response,
        ),
      );
    } catch (e) {
      _setState(
        state.copyWith(
          vehicleCheckStatus: HomeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> getProductAmountByDealer(Map<String, dynamic> data) async {
    debugPrint("Hitting get_product_amount_by_dealer.php with: $data");
    _setState(state.copyWith(productAmountStatus: HomeStatus.loading));
    try {
      final response = await repository.getProductAmountByDealerRepo(data);
      // Based on typical API response structure
      if (response['status'] == 'success' || response['status'] == true) {
        _setState(
          state.copyWith(
            productAmountStatus: HomeStatus.success,
            productAmount: response['amount'].toString(),
            totalDuesPending:
                (response['total_pending_amount'] ??
                        response['total_dues_peding'] ??
                        response['total_dues_pending'])
                    ?.toString(),
          ),
        );
      } else {
        _setState(
          state.copyWith(
            productAmountStatus: HomeStatus.error,
            errorMessage: response['message'] ?? "Failed to fetch amount",
          ),
        );
      }
    } catch (e) {
      _setState(
        state.copyWith(
          productAmountStatus: HomeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void setIsRetailCustomer(bool value) {
    _setState(state.copyWith(isRetailCustomer: value));
  }

  Future<void> getVehicleFormat() async {
    _setState(state.copyWith(vehicleFormatStatus: HomeStatus.loading));
    try {
      final data = await repository.getVehicleFormatRepo();
      _setState(
        state.copyWith(
          vehicleFormatStatus: HomeStatus.success,
          vehicleFormatData: data,
        ),
      );
    } catch (e) {
      _setState(
        state.copyWith(
          vehicleFormatStatus: HomeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> getCertificateList(String id, String role) async {
    if (role == 'role_1') {
      _setState(state.copyWith(role1CertificateListStatus: HomeStatus.loading));
    } else {
      _setState(state.copyWith(role2CertificateListStatus: HomeStatus.loading));
    }

    try {
      final data = (role == 'role_1')
          ? await repository.getCertificateListRole1(id)
          : await repository.getCertificateListRole2(id);

      print(
        "📊 RECEIVED CERTIFICATES FOR $role: ${data.role1certificateList?.length ?? 0}",
      );

      if (role == 'role_1') {
        _setState(
          state.copyWith(
            role1CertificateListStatus: HomeStatus.success,
            role1CertificateListData: data,
            // Keeping for backward compatibility if needed temporarily
            certificateListStatus: HomeStatus.success,
            certificateListData: data,
          ),
        );
      } else {
        _setState(
          state.copyWith(
            role2CertificateListStatus: HomeStatus.success,
            role2CertificateListData: data,
            // Keeping for backward compatibility if needed temporarily
            certificateListStatus: HomeStatus.success,
            certificateListData: data,
          ),
        );
      }
    } catch (e, stacktrace) {
      print("❌ ERROR FETCHING CERTIFICATES FOR $role: $e");
      print(stacktrace);
      if (role == 'role_1') {
        _setState(
          state.copyWith(
            role1CertificateListStatus: HomeStatus.error,
            errorMessage: e.toString(),
          ),
        );
      } else {
        _setState(
          state.copyWith(
            role2CertificateListStatus: HomeStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    }
  }

  Future<bool> updateRole1Certificate(
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    _setState(state.copyWith(certificateStatus: HomeStatus.loading));
    try {
      final response = await repository.updateCertificateRole1(data);
      if (response.success) {
        _setState(state.copyWith(certificateStatus: HomeStatus.success));
        final authRepo = context.read<AuthRepository>();
        final userId = await authRepo.getUserId();
        final role = await authRepo.getUserType();
        getCertificateList(userId ?? '', role ?? 'role_1');
        clearDealerAmount();
        clearProductAmount();
        return true;
      } else {
        _setState(state.copyWith(certificateStatus: HomeStatus.error));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      _setState(state.copyWith(certificateStatus: HomeStatus.error));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }

  Future<bool> submitRole2Certificate(
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    _setState(state.copyWith(certificateStatus: HomeStatus.loading));
    try {
      final response = await repository.saveCertificateRole2(data);
      print('--- Certificate Data --------------------${data}');

      if (response.success) {
        _setState(state.copyWith(certificateStatus: HomeStatus.success));
        final authRepo = context.read<AuthRepository>();
        final userId = await authRepo.getUserId();
        final adminId = await authRepo.getAdminId();
        final role = await authRepo.getUserType();
        getCertificateList(
          (role == 'role_2' ? adminId : userId) ?? '',
          role ?? 'role_1',
        );
        clearDealerAmount();
        clearProductAmount();
        clearSelectedProductAndType();
        return true;
      } else {
        _setState(state.copyWith(certificateStatus: HomeStatus.error));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      _setState(state.copyWith(certificateStatus: HomeStatus.error));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }

  Future<bool> submitRejectedCylinder(
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    _setState(state.copyWith(certificateStatus: HomeStatus.loading));
    try {
      final response = await repository.saveRejectedCylinder(data);
      if (response.success) {
        _setState(state.copyWith(certificateStatus: HomeStatus.success));
        final authRepo = context.read<AuthRepository>();
        final userId = await authRepo.getUserId();
        final adminId = await authRepo.getAdminId();
        final role = await authRepo.getUserType();

        getCertificateList(
          (role == 'role_2' ? adminId : userId) ?? '',
          role ?? 'role_1',
        );
        clearDealerAmount();
        clearProductAmount();
        clearSelectedProductAndType();
        return true;
      } else {
        _setState(state.copyWith(certificateStatus: HomeStatus.error));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      _setState(state.copyWith(certificateStatus: HomeStatus.error));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }

  Future<bool> updateRole2Certificate(
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    _setState(state.copyWith(certificateStatus: HomeStatus.loading));
    try {
      final response = await repository.updateCertificateRole2(data);
      if (response.success) {
        _setState(state.copyWith(certificateStatus: HomeStatus.success));
        final authRepo = context.read<AuthRepository>();
        final userId = await authRepo.getUserId();
        final adminId = await authRepo.getAdminId();
        final role = await authRepo.getUserType();

        getCertificateList(
          (role == 'role_2' ? adminId : userId) ?? '',
          role ?? 'role_1',
        );
        clearDealerAmount();
        clearProductAmount();
        return true;
      } else {
        _setState(state.copyWith(certificateStatus: HomeStatus.error));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      _setState(state.copyWith(certificateStatus: HomeStatus.error));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }

  Future<void> getPaymentMaster() async {
    _setState(state.copyWith(paymentMasterStatus: HomeStatus.loading));
    try {
      final data = await repository.getPaymentMaster();
      _setState(
        state.copyWith(
          paymentMasterStatus: HomeStatus.success,
          paymentMasterData: data,
        ),
      );
    } catch (e) {
      _setState(
        state.copyWith(
          paymentMasterStatus: HomeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> getTransactionHistory(String certId) async {
    _setState(state.copyWith(transactionHistoryStatus: HomeStatus.loading));
    try {
      final data = await repository.getTransactionHistory(certId);
      _setState(
        state.copyWith(
          transactionHistoryStatus: HomeStatus.success,
          transactionHistoryData: data,
        ),
      );
    } catch (e) {
      _setState(
        state.copyWith(
          transactionHistoryStatus: HomeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<bool> savePaymentRole1(Map<String, dynamic> paymentData) async {
    _setState(state.copyWith(certificateStatus: HomeStatus.loading));
    try {
      final success = await repository.savePaymentRole1(paymentData);
      if (success) {
        _setState(state.copyWith(certificateStatus: HomeStatus.success));
        return true;
      }
      _setState(state.copyWith(certificateStatus: HomeStatus.error));
      return false;
    } catch (e) {
      _setState(state.copyWith(certificateStatus: HomeStatus.error));
      return false;
    }
  }

  Future<bool> updatePrintStatus(String certificateId) async {
    try {
      return await repository.updatePrintStatus(certificateId);
    } catch (e) {
      return false;
    }
  }

  void clearProductAmount() {
    _setState(
      state.copyWith(
        productAmount: null,
        totalDuesPending: null,
        productAmountStatus: HomeStatus.initial,
      ),
    );
  }

  void clearSelectedProductAndType() {
    _setState(
      HomeState(
        status: state.status,
        vehicleTypeStatus: state.vehicleTypeStatus,
        certificateStatus: state.certificateStatus,
        dealerTypeStatus: state.dealerTypeStatus,
        vehicleFormatStatus: state.vehicleFormatStatus,
        certificateListStatus: state.certificateListStatus,
        role1CertificateListStatus: state.role1CertificateListStatus,
        role2CertificateListStatus: state.role2CertificateListStatus,
        cylinderMakeStatus: state.cylinderMakeStatus,
        dealerAmountStatus: state.dealerAmountStatus,
        paymentMasterStatus: state.paymentMasterStatus,
        transactionHistoryStatus: state.transactionHistoryStatus,
        vehicleCheckStatus: state.vehicleCheckStatus,
        productAmountStatus: state.productAmountStatus,
        homeData: state.homeData,
        vehicleTypeData: state.vehicleTypeData,
        dealerTypeData: state.dealerTypeData,
        vehicleFormatData: state.vehicleFormatData,
        certificateListData: state.certificateListData,
        role1CertificateListData: state.role1CertificateListData,
        role2CertificateListData: state.role2CertificateListData,
        cylinderMakeData: state.cylinderMakeData,
        paymentMasterData: state.paymentMasterData,
        transactionHistoryData: state.transactionHistoryData,
        vehicleCheckData: state.vehicleCheckData,
        productAmount: state.productAmount,
        dealerAmount: state.dealerAmount,
        dealerPendingAmount: state.dealerPendingAmount,
        totalDuesPending: state.totalDuesPending,
        dealerPtStatus: state.dealerPtStatus,
        searchQuery: state.searchQuery,
        certificateResult: state.certificateResult,
        errorMessage: state.errorMessage,
        selectedProduct: null,
        selectedCylinderType: null,
        isRetailCustomer: state.isRetailCustomer,
        photoRequired: state.photoRequired,
      ),
    );
  }

  Future<List<String>> getProductStandardName(String productId) async {
    try {
      final response = await repository.getProductStandardNameRepo(productId);
      if (response != null &&
          response is Map &&
          response['status'] == 'success') {
        if (response['standard_name'] is List) {
          return (response['standard_name'] as List)
              .map((e) => e.toString())
              .toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching product standard name: $e");
    }
    return [];
  }
}
