import 'package:equatable/equatable.dart';

class VehicleTypeModel extends Equatable {
  final String? status;
  final int? count;
  final List<VehicleTypeData>? data;
  final List<CylinderCapacityData>? cylinderCapacity;

  const VehicleTypeModel({
    this.status,
    this.count,
    this.data,
    this.cylinderCapacity,
  });

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeModel(
      status: json['status'],
      count: json['count'],
      data: json['data'] != null
          ? (json['data'] as List).map((v) => VehicleTypeData.fromJson(v)).toList()
          : null,
      cylinderCapacity: json['cylinder_capacity'] != null
          ? (json['cylinder_capacity'] as List)
              .map((v) => CylinderCapacityData.fromJson(v))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['count'] = count;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (cylinderCapacity != null) {
      data['cylinder_capacity'] = cylinderCapacity!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  List<Object?> get props => [status, count, data, cylinderCapacity];
}

class VehicleTypeData extends Equatable {
  final int? id;
  final String? vehicleName;
  final String? createdAt;
  final String? updatedAt;

  const VehicleTypeData({this.id, this.vehicleName, this.createdAt, this.updatedAt});

  factory VehicleTypeData.fromJson(Map<String, dynamic> json) {
    return VehicleTypeData(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ??
              json['vehicle_id']?.toString() ??
              ""),
      vehicleName: json['vehicle_name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['vehicle_name'] = vehicleName;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  @override
  List<Object?> get props => [id, vehicleName, createdAt, updatedAt];
}

class CylinderCapacityData extends Equatable {
  final String? cylinderCapacity;

  const CylinderCapacityData({this.cylinderCapacity});

  factory CylinderCapacityData.fromJson(Map<String, dynamic> json) {
    return CylinderCapacityData(
      cylinderCapacity: json['cylinder_capacity']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cylinder_capacity'] = cylinderCapacity;
    return data;
  }

  @override
  List<Object?> get props => [cylinderCapacity];
}
