import 'package:equatable/equatable.dart';

class VehicleFormatModel extends Equatable {
  final String? status;
  final int? count;
  final List<VehicleFormatData>? data;

  const VehicleFormatModel({this.status, this.count, this.data});

  factory VehicleFormatModel.fromJson(Map<String, dynamic> json) {
    return VehicleFormatModel(
      status: json['status'],
      count: json['count'],
      data: json['data'] != null
          ? (json['data'] as List).map((v) => VehicleFormatData.fromJson(v)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'count': count,
      'data': data?.map((v) => v.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [status, count, data];
}

class VehicleFormatData extends Equatable {
  final int? id;
  final String? vFormat;
  final String? createdAt;
  final String? updatedAt;

  const VehicleFormatData({this.id, this.vFormat, this.createdAt, this.updatedAt});

  factory VehicleFormatData.fromJson(Map<String, dynamic> json) {
    return VehicleFormatData(
      id: json['id'],
      vFormat: json['v_format'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'v_format': vFormat,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [id, vFormat, createdAt, updatedAt];
}
