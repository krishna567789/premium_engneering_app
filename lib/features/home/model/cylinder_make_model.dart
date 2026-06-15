class CylinderMakeModel {
  String? status;
  int? count;
  List<CylinderData>? data;

  CylinderMakeModel({this.status, this.count, this.data});

  CylinderMakeModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    count = json['count'];
    if (json['data'] != null) {
      data = <CylinderData>[];
      json['data'].forEach((v) {
        data!.add(CylinderData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['count'] = count;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CylinderData {
  int? id;
  String? fullname;
  String? shortname;
  String? createdAt;
  String? updatedAt;

  CylinderData({
    this.id,
    this.fullname,
    this.shortname,
    this.createdAt,
    this.updatedAt,
  });

  CylinderData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullname = json['fullname'];
    shortname = json['shortname'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['fullname'] = fullname;
    data['shortname'] = shortname;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
