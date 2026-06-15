import 'package:equatable/equatable.dart';
import 'package:premium_engneering_app/features/home/model/cylinder_make_model.dart';
import 'package:premium_engneering_app/features/home/model/dealer_type_model.dart' hide Data;
import 'package:premium_engneering_app/features/home/model/home_model.dart';
import 'package:premium_engneering_app/features/home/model/vehicle_format_model.dart';
import 'package:premium_engneering_app/features/home/model/role1_certificate_list_model.dart';
import 'package:premium_engneering_app/features/home/model/vehicle_type_model.dart';
import 'package:premium_engneering_app/features/home/model/payment_master_model.dart';
import 'package:premium_engneering_app/features/home/model/payment_transaction_model.dart';

enum HomeStatus { initial, loading, success, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final HomeStatus vehicleTypeStatus;
  final HomeStatus certificateStatus;
  final HomeStatus dealerTypeStatus;
  final HomeStatus vehicleFormatStatus;
  final HomeStatus certificateListStatus;
  final HomeStatus role1CertificateListStatus;
  final HomeStatus role2CertificateListStatus;
  final HomeStatus cylinderMakeStatus;
  final HomeStatus dealerAmountStatus;
  final HomeStatus paymentMasterStatus;
  final HomeStatus transactionHistoryStatus;
  final HomeStatus vehicleCheckStatus;
  final HomeStatus productAmountStatus;
  final HomeModel? homeData;
  final VehicleTypeModel? vehicleTypeData;
  final DelearTypeModel? dealerTypeData;
  final VehicleFormatModel? vehicleFormatData;
  final Role1CertificateListModel? certificateListData;
  final Role1CertificateListModel? role1CertificateListData;
  final Role1CertificateListModel? role2CertificateListData;
  final CylinderMakeModel? cylinderMakeData;
  final PaymentMasterModel? paymentMasterData;
  final PaymentTransactionModel? transactionHistoryData;
  final dynamic vehicleCheckData;
  final String? productAmount;
  final String? dealerAmount;
  final String? dealerPendingAmount;
  final String? totalDuesPending;
  final String searchQuery;
  final dynamic certificateResult;
  final String? dealerPtStatus;
  final String? errorMessage;
  final Data? selectedProduct;
  final String? selectedCylinderType;
  final bool isRetailCustomer;
  final bool photoRequired;

  const HomeState({
    this.status = HomeStatus.initial,
    this.vehicleTypeStatus = HomeStatus.initial,
    this.certificateStatus = HomeStatus.initial,
    this.dealerTypeStatus = HomeStatus.initial,
    this.vehicleFormatStatus = HomeStatus.initial,
    this.certificateListStatus = HomeStatus.initial,
    this.role1CertificateListStatus = HomeStatus.initial,
    this.role2CertificateListStatus = HomeStatus.initial,
    this.cylinderMakeStatus = HomeStatus.initial,
    this.dealerAmountStatus = HomeStatus.initial,
    this.paymentMasterStatus = HomeStatus.initial,
    this.transactionHistoryStatus = HomeStatus.initial,
    this.vehicleCheckStatus = HomeStatus.initial,
    this.productAmountStatus = HomeStatus.initial,
    this.homeData,
    this.vehicleTypeData,
    this.dealerTypeData,
    this.vehicleFormatData,
    this.certificateListData,
    this.role1CertificateListData,
    this.role2CertificateListData,
    this.cylinderMakeData,
    this.paymentMasterData,
    this.transactionHistoryData,
    this.vehicleCheckData,
    this.productAmount,
    this.dealerAmount,
    this.dealerPendingAmount,
    this.totalDuesPending,
    this.dealerPtStatus,
    this.searchQuery = "",
    this.certificateResult,
    this.errorMessage,
    this.selectedProduct,
    this.selectedCylinderType,
    this.isRetailCustomer = false,
    this.photoRequired = true, // Default to true to maintain existing behavior if API fails or not provided
  });

  HomeState copyWith({
    HomeStatus? status,
    HomeStatus? vehicleTypeStatus,
    HomeStatus? certificateStatus,
    HomeStatus? dealerTypeStatus,
    HomeStatus? vehicleFormatStatus,
    HomeStatus? certificateListStatus,
    HomeStatus? role1CertificateListStatus,
    HomeStatus? role2CertificateListStatus,
    HomeStatus? cylinderMakeStatus,
    HomeStatus? dealerAmountStatus,
    HomeStatus? paymentMasterStatus,
    HomeStatus? transactionHistoryStatus,
    HomeStatus? vehicleCheckStatus,
    HomeStatus? productAmountStatus,
    HomeModel? homeData,
    VehicleTypeModel? vehicleTypeData,
    DelearTypeModel? dealerTypeData,
    VehicleFormatModel? vehicleFormatData,
    Role1CertificateListModel? certificateListData,
    Role1CertificateListModel? role1CertificateListData,
    Role1CertificateListModel? role2CertificateListData,
    CylinderMakeModel? cylinderMakeData,
    PaymentMasterModel? paymentMasterData,
    PaymentTransactionModel? transactionHistoryData,
    dynamic vehicleCheckData,
    String? productAmount,
    String? dealerAmount,
    String? dealerPendingAmount,
    String? totalDuesPending,
    String? dealerPtStatus,
    String? searchQuery,
    dynamic certificateResult,
    String? errorMessage,
    Data? selectedProduct,
    String? selectedCylinderType,
    bool? isRetailCustomer,
    bool? photoRequired,
  }) {
    return HomeState(
      status: status ?? this.status,
      vehicleTypeStatus: vehicleTypeStatus ?? this.vehicleTypeStatus,
      certificateStatus: certificateStatus ?? this.certificateStatus,
      dealerTypeStatus: dealerTypeStatus ?? this.dealerTypeStatus,
      vehicleFormatStatus: vehicleFormatStatus ?? this.vehicleFormatStatus,
      certificateListStatus:
          certificateListStatus ?? this.certificateListStatus,
      role1CertificateListStatus:
          role1CertificateListStatus ?? this.role1CertificateListStatus,
      role2CertificateListStatus:
          role2CertificateListStatus ?? this.role2CertificateListStatus,
      cylinderMakeStatus: cylinderMakeStatus ?? this.cylinderMakeStatus,
      dealerAmountStatus: dealerAmountStatus ?? this.dealerAmountStatus,
      paymentMasterStatus: paymentMasterStatus ?? this.paymentMasterStatus,
      transactionHistoryStatus:
          transactionHistoryStatus ?? this.transactionHistoryStatus,
      vehicleCheckStatus: vehicleCheckStatus ?? this.vehicleCheckStatus,
      productAmountStatus: productAmountStatus ?? this.productAmountStatus,
      homeData: homeData ?? this.homeData,
      vehicleTypeData: vehicleTypeData ?? this.vehicleTypeData,
      dealerTypeData: dealerTypeData ?? this.dealerTypeData,
      vehicleFormatData: vehicleFormatData ?? this.vehicleFormatData,
      certificateListData: certificateListData ?? this.certificateListData,
      role1CertificateListData:
          role1CertificateListData ?? this.role1CertificateListData,
      role2CertificateListData:
          role2CertificateListData ?? this.role2CertificateListData,
      cylinderMakeData: cylinderMakeData ?? this.cylinderMakeData,
      paymentMasterData: paymentMasterData ?? this.paymentMasterData,
      transactionHistoryData:
          transactionHistoryData ?? this.transactionHistoryData,
      vehicleCheckData: vehicleCheckData ?? this.vehicleCheckData,
      productAmount: productAmount ?? this.productAmount,
      dealerAmount: dealerAmount ?? this.dealerAmount,
      dealerPendingAmount: dealerPendingAmount ?? this.dealerPendingAmount,
      totalDuesPending: totalDuesPending ?? this.totalDuesPending,
      dealerPtStatus: dealerPtStatus ?? this.dealerPtStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      certificateResult: certificateResult ?? this.certificateResult,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      selectedCylinderType: selectedCylinderType ?? this.selectedCylinderType,
      isRetailCustomer: isRetailCustomer ?? this.isRetailCustomer,
      photoRequired: photoRequired ?? this.photoRequired,
    );
  }

  @override
  List<Object?> get props => [
    status,
    vehicleTypeStatus,
    certificateStatus,
    dealerTypeStatus,
    vehicleFormatStatus,
    certificateListStatus,
    role1CertificateListStatus,
    role2CertificateListStatus,
    cylinderMakeStatus,
    dealerAmountStatus,
    paymentMasterStatus,
    transactionHistoryStatus,
    vehicleCheckStatus,
    productAmountStatus,
    homeData,
    vehicleTypeData,
    dealerTypeData,
    vehicleFormatData,
    certificateListData,
    role1CertificateListData,
    role2CertificateListData,
    cylinderMakeData,
    paymentMasterData,
    transactionHistoryData,
    vehicleCheckData,
    productAmount,
    dealerAmount,
    dealerPendingAmount,
    totalDuesPending,
    dealerPtStatus,
    searchQuery,
    certificateResult,
    errorMessage,
    selectedProduct,
    selectedCylinderType,
    isRetailCustomer,
    photoRequired,
  ];
}
