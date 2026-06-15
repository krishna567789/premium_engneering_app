import 'package:equatable/equatable.dart';

class DelearTypeModel extends Equatable {
  final String? status;
  final List<Data>? data;

  const DelearTypeModel({this.status, this.data});

  factory DelearTypeModel.fromJson(Map<String, dynamic> json) {
    return DelearTypeModel(
      status: json['status'],
      data: json['data'] != null
          ? List<Data>.from(json['data'].map((v) => Data.fromJson(v)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'data': data?.map((v) => v.toJson()).toList()};
  }

  @override
  List<Object?> get props => [status, data];
}

class Data extends Equatable {
  final int? id;
  final String? adminId;
  final String? fullname;
  final String? mobileNo;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  const Data({
    this.id,
    this.adminId,
    this.fullname,
    this.mobileNo,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      adminId: json['admin_id'],
      fullname: json['fullname'],
      mobileNo: json['mobile_no'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admin_id': adminId,
      'fullname': fullname,
      'mobile_no': mobileNo,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    id,
    adminId,
    fullname,
    mobileNo,
    status,
    createdAt,
    updatedAt,
  ];
}
