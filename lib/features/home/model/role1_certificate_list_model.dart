import 'package:equatable/equatable.dart';

class Role1CertificateListModel extends Equatable {
  final String? status;
  final List<CertificateData>? role1certificateList;

  const Role1CertificateListModel({this.status, this.role1certificateList});

  factory Role1CertificateListModel.fromJson(Map<String, dynamic> json) {
    var listData = json['role1certificateList'] ?? json['certificateList'] ?? json['data'];
    
    List<CertificateData> certificates = [];
    if (listData != null) {
      if (listData is List) {
        certificates = List<CertificateData>.from(
          listData.map((v) => CertificateData.fromJson(v)),
        );
      } else if (listData is Map<String, dynamic>) {
        // Handle single object response by wrapping it in a list
        certificates = [CertificateData.fromJson(listData)];
      }
    }

    return Role1CertificateListModel(
      status: json['status'],
      role1certificateList: certificates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'role1certificateList': role1certificateList
          ?.map((v) => v.toJson())
          .toList(),
    };
  }

  @override
  List<Object?> get props => [status, role1certificateList];
}

class CertificateData extends Equatable {
  final int? id;
  final int? adminId;
  final String? insertDataBy;
  final String? licenseName;
  final String? approvalNo;
  final String? certificateNo;
  final String? cNo;
  final String? vehicalType;
  final String? vehicleNumber;
  final String? vehicleFormat;
  final String? cascadeNumber;
  final String? cascadeNo;
  final String? collectionDate;
  final String? testDate;
  final String? nextTestDate;
  final String? productType;
  final String? specification;
  final String? cylinderSerialNo;
  final String? lastTestDate;
  final String? cylinderMake;
  final String? manufacturingDate;
  final String? cceFillingPermissionNo;
  final String? fillingPermissionDate;
  final String? expireDate;
  final dynamic valveInspection;
  final String? valveInspectionRemark;
  final dynamic visualInspection;
  final String? visualInspectionRemark;
  final dynamic cylinderThreading;
  final String? cylinderThreadingRemark;
  final dynamic internalInspection;
  final String? internalInspectionRemark;
  final String? originalTareWeight;
  final String? actualWeight;
  final String? lossOfWeight;
  final String? lossOfWeightPercentage;
  final dynamic painting;
  final String? dieOfCylinder;
  final String? shellMinCalThick;
  final String? shellObsThickMin;
  final String? bottomMinCalThick;
  final String? bottomObsThickMin;
  final String? waterCapacity;
  final String? workingPressure;
  final String? testPressure;
  final String? initialExpansion;
  final String? totalExpansion;
  final String? permanentExpansion;
  final String? permanentExpansionPercentage;
  final String? result;
  final String? photoNumberPlate;
  final String? photoMarkingDetails;
  final String? remark;
  final String? paymentMode;
  final String? paymentAmount;
  final String? retailerAmount;
  final String? pendingAmtInOffices;
  final String? payDate;
  final String? payCollectedBy;
  final String? payOfficesStatus;
  final String? payStatus;
  final String? dealerId;
  final String? mobile;
  final int? status;
  final String? createdAt;
  final String? dealerName;
  final dynamic pendingAmount;
  final String? ptStatus;
  final String? ptModeStatus;
  final String? displayNumber;
  const CertificateData({
    this.id,
    this.adminId,
    this.insertDataBy,
    this.licenseName,
    this.approvalNo,
    this.certificateNo,
    this.cNo,
    this.vehicalType,
    this.vehicleNumber,
    this.vehicleFormat,
    this.cascadeNumber,
    this.cascadeNo,
    this.collectionDate,
    this.testDate,
    this.nextTestDate,
    this.productType,
    this.specification,
    this.cylinderSerialNo,
    this.lastTestDate,
    this.cylinderMake,
    this.manufacturingDate,
    this.cceFillingPermissionNo,
    this.fillingPermissionDate,
    this.expireDate,
    this.valveInspection,
    this.valveInspectionRemark,
    this.visualInspection,
    this.visualInspectionRemark,
    this.cylinderThreading,
    this.cylinderThreadingRemark,
    this.internalInspection,
    this.internalInspectionRemark,
    this.originalTareWeight,
    this.actualWeight,
    this.lossOfWeight,
    this.lossOfWeightPercentage,
    this.painting,
    this.dieOfCylinder,
    this.shellMinCalThick,
    this.shellObsThickMin,
    this.bottomMinCalThick,
    this.bottomObsThickMin,
    this.waterCapacity,
    this.workingPressure,
    this.testPressure,
    this.initialExpansion,
    this.totalExpansion,
    this.permanentExpansion,
    this.permanentExpansionPercentage,
    this.result,
    this.photoNumberPlate,
    this.photoMarkingDetails,
    this.remark,
    this.paymentMode,
    this.paymentAmount,
    this.retailerAmount,
    this.pendingAmtInOffices,
    this.payDate,
    this.payCollectedBy,
    this.payOfficesStatus,
    this.payStatus,
    this.dealerId,
    this.mobile,
    this.status,
    this.createdAt,
    this.dealerName,
    this.pendingAmount,
    this.ptStatus,
    this.ptModeStatus,
    this.displayNumber,
  });

  factory CertificateData.fromJson(Map<String, dynamic> json) {
    return CertificateData(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ""),
      adminId: json['admin_id'] is int
          ? json['admin_id']
          : int.tryParse(json['admin_id']?.toString() ?? ""),
      insertDataBy: json['insert_data_by']?.toString(),
      licenseName: json['license_name']?.toString(),
      approvalNo: json['approval_no']?.toString(),
      certificateNo: json['certificate_no']?.toString(),
      cNo: json['c_no']?.toString(),
      vehicalType: (json['vehicle_type'] ?? json['vehical_type'])?.toString(),
      vehicleNumber: json['vehicle_number']?.toString(),
      vehicleFormat: json['vehicle_format']?.toString(),
      cascadeNumber: json['cascade_number']?.toString(),
      cascadeNo: json['cascade_no']?.toString(),
      collectionDate: json['collection_date']?.toString(),
      testDate: json['test_date']?.toString(),
      nextTestDate: json['next_test_date']?.toString(),
      productType: json['product_type']?.toString(),
      specification: json['specification']?.toString(),
      cylinderSerialNo: json['cylinder_serial_no']?.toString(),
      lastTestDate: json['last_test_date']?.toString(),
      cylinderMake: json['cylinder_make']?.toString(),
      manufacturingDate: json['manufacturing_date']?.toString(),
      cceFillingPermissionNo: json['cce_filling_permission_no']?.toString(),
      fillingPermissionDate: json['filling_permission_date']?.toString(),
      expireDate: json['expire_date']?.toString(),
      valveInspection: json['valve_inspection'],
      valveInspectionRemark: json['valve_inspection_remark']?.toString(),
      visualInspection: json['visual_inspection'],
      visualInspectionRemark: json['visual_inspection_remark']?.toString(),
      cylinderThreading: json['cylinder_threading'],
      cylinderThreadingRemark: json['cylinder_threading_remark']?.toString(),
      internalInspection: json['internal_inspection'],
      internalInspectionRemark: json['internal_inspection_remark']?.toString(),
      originalTareWeight: json['original_tare_weight']?.toString(),
      actualWeight: json['actual_weight']?.toString(),
      lossOfWeight: json['loss_of_weight']?.toString(),
      lossOfWeightPercentage: json['loss_of_weight_percentage']?.toString(),
      painting: json['painting'],
      dieOfCylinder: json['die_of_cylinder']?.toString(),
      shellMinCalThick: json['shell_min_cal_thick']?.toString(),
      shellObsThickMin: json['shell_obs_thick_min']?.toString(),
      bottomMinCalThick: json['bottom_min_cal_thick']?.toString(),
      bottomObsThickMin: json['bottom_obs_thick_min']?.toString(),
      waterCapacity: json['water_capacity']?.toString(),
      workingPressure: json['working_pressure']?.toString(),
      testPressure: json['test_pressure']?.toString(),
      initialExpansion: json['initial_expansion']?.toString(),
      totalExpansion: json['total_expansion']?.toString(),
      permanentExpansion: json['permanent_expansion']?.toString(),
      permanentExpansionPercentage: json['permanent_expansion_percentage']
          ?.toString(),
      result: json['result']?.toString(),
      photoNumberPlate: json['photo_number_plate']?.toString(),
      photoMarkingDetails: json['photo_marking_details']?.toString(),
      remark: json['remark']?.toString(),
      paymentMode: json['payment_mode']?.toString(),
      paymentAmount: json['payment_amount']?.toString(),
      retailerAmount: json['retailer_amount']?.toString(),
      pendingAmtInOffices: json['pending_amt_in_offices']?.toString(),
      payDate: json['pay_date']?.toString(),
      payCollectedBy: json['pay_collected_by']?.toString(),
      payOfficesStatus: json['pay_offices_status']?.toString(),
      payStatus: json['pay_status']?.toString(),
      dealerId: json['dealer_id']?.toString(),
      mobile: json['mobile']?.toString(),
      status: json['status'] is int
          ? json['status']
          : int.tryParse(json['status']?.toString() ?? ""),
      createdAt: json['created_at']?.toString(),
      dealerName: json['dealer_name']?.toString(),
      pendingAmount: json['pending_amount'],
      ptStatus: json['pt_status']?.toString(),
      ptModeStatus: (json['pt_mode_status'] ?? json['p_mode_status'])?.toString(),
      displayNumber: json['display_number']?.toString(),
    );
  }



  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admin_id': adminId,
      'insert_data_by': insertDataBy,
      'license_name': licenseName,
      'approval_no': approvalNo,
      'certificate_no': certificateNo,
      'c_no': cNo,
      'vehical_type': vehicalType,
      'vehicle_number': vehicleNumber,
      'vehicle_format': vehicleFormat,
      'cascade_number': cascadeNumber,
      'cascade_no': cascadeNo,
      'collection_date': collectionDate,
      'test_date': testDate,
      'next_test_date': nextTestDate,
      'product_type': productType,
      'specification': specification,
      'cylinder_serial_no': cylinderSerialNo,
      'last_test_date': lastTestDate,
      'cylinder_make': cylinderMake,
      'manufacturing_date': manufacturingDate,
      'cce_filling_permission_no': cceFillingPermissionNo,
      'filling_permission_date': fillingPermissionDate,
      'expire_date': expireDate,
      'valve_inspection': valveInspection,
      'valve_inspection_remark': valveInspectionRemark,
      'visual_inspection': visualInspection,
      'visual_inspection_remark': visualInspectionRemark,
      'cylinder_threading': cylinderThreading,
      'cylinder_threading_remark': cylinderThreadingRemark,
      'internal_inspection': internalInspection,
      'internal_inspection_remark': internalInspectionRemark,
      'original_tare_weight': originalTareWeight,
      'actual_weight': actualWeight,
      'loss_of_weight': lossOfWeight,
      'loss_of_weight_percentage': lossOfWeightPercentage,
      'painting': painting,
      'die_of_cylinder': dieOfCylinder,
      'shell_min_cal_thick': shellMinCalThick,
      'shell_obs_thick_min': shellObsThickMin,
      'bottom_min_cal_thick': bottomMinCalThick,
      'bottom_obs_thick_min': bottomObsThickMin,
      'water_capacity': waterCapacity,
      'working_pressure': workingPressure,
      'test_pressure': testPressure,
      'initial_expansion': initialExpansion,
      'total_expansion': totalExpansion,
      'permanent_expansion': permanentExpansion,
      'permanent_expansion_percentage': permanentExpansionPercentage,
      'result': result,
      'photo_number_plate': photoNumberPlate,
      'photo_marking_details': photoMarkingDetails,
      'remark': remark,
      'payment_mode': paymentMode,
      'payment_amount': paymentAmount,
      'retailer_amount': retailerAmount,
      'pending_amt_in_offices': pendingAmtInOffices,
      'pay_date': payDate,
      'pay_collected_by': payCollectedBy,
      'pay_offices_status': payOfficesStatus,
      'pay_status': payStatus,
      'dealer_id': dealerId,
      'mobile': mobile,
      'status': status,
      'created_at': createdAt,
      'dealer_name': dealerName,
      'pending_amount': pendingAmount,
      'pt_status': ptStatus,
      'pt_mode_status': ptModeStatus,
      'display_number': displayNumber,
    };
  }

  @override
  List<Object?> get props => [
    id,
    adminId,
    insertDataBy,
    licenseName,
    approvalNo,
    certificateNo,
    cNo,
    vehicalType,
    vehicleNumber,
    vehicleFormat,
    cascadeNumber,
    cascadeNo,
    collectionDate,
    testDate,
    nextTestDate,
    productType,
    specification,
    cylinderSerialNo,
    lastTestDate,
    cylinderMake,
    manufacturingDate,
    cceFillingPermissionNo,
    fillingPermissionDate,
    expireDate,
    valveInspection,
    valveInspectionRemark,
    visualInspection,
    visualInspectionRemark,
    cylinderThreading,
    cylinderThreadingRemark,
    internalInspection,
    internalInspectionRemark,
    originalTareWeight,
    actualWeight,
    lossOfWeight,
    lossOfWeightPercentage,
    painting,
    dieOfCylinder,
    shellMinCalThick,
    shellObsThickMin,
    bottomMinCalThick,
    bottomObsThickMin,
    waterCapacity,
    workingPressure,
    testPressure,
    initialExpansion,
    totalExpansion,
    permanentExpansion,
    permanentExpansionPercentage,
    result,
    photoNumberPlate,
    photoMarkingDetails,
    remark,
    paymentMode,
    paymentAmount,
    retailerAmount,
    pendingAmtInOffices,
    payDate,
    payCollectedBy,
    payOfficesStatus,
    payStatus,
    dealerId,
    mobile,
    status,
    createdAt,
    dealerName,
    pendingAmount,
    ptStatus,
    ptModeStatus,
    displayNumber,
  ];
}
