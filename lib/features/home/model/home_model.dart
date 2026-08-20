import 'package:equatable/equatable.dart';

class HomeModel extends Equatable {
  final String? status;
  final int? count;
  final List<Data>? data;

  const HomeModel({this.status, this.count, this.data});

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      status: json['status'],
      count: json['count'],
      data: json['data'] != null
          ? (json['data'] as List).map((i) => Data.fromJson(i)).toList()
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
    return data;
  }

  @override
  List<Object?> get props => [status, count, data];
}

class Data extends Equatable {
  final int? id;
  final String? fullname;
  final String? shortname;
  final String? dueDate;
  final String? standard;
  final String? testingPressure;
  final String? workingPressure;
  final String? typeOfCylinder;
  final String? expansionRejection;
  final String? weightRejection;
  final int? lifeOfCylinder;
  final int? intervalTesting;
  final String? createdAt;
  final String? updatedAt;

  const Data({
    this.id,
    this.fullname,
    this.shortname,
    this.dueDate,
    this.standard,
    this.testingPressure,
    this.workingPressure,
    this.typeOfCylinder,
    this.expansionRejection,
    this.weightRejection,
    this.lifeOfCylinder,
    this.intervalTesting,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      fullname: json['fullname'],
      shortname: json['shortname'],
      dueDate: json['due_date'],
      standard: json['standard'],
      testingPressure: json['testing_pressure'],
      workingPressure: json['working_pressure'],
      typeOfCylinder: json['type_of_cylinder'],
      expansionRejection: json['expansion_rejection'],
      weightRejection: json['weight_rejection'],
      lifeOfCylinder: json['life_of_cylinder'],
      intervalTesting: json['interval_testing'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['fullname'] = fullname;
    data['shortname'] = shortname;
    data['due_date'] = dueDate;
    data['standard'] = standard;
    data['testing_pressure'] = testingPressure;
    data['working_pressure'] = workingPressure;
    data['type_of_cylinder'] = typeOfCylinder;
    data['expansion_rejection'] = expansionRejection;
    data['weight_rejection'] = weightRejection;
    data['life_of_cylinder'] = lifeOfCylinder;
    data['interval_testing'] = intervalTesting;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  @override
  List<Object?> get props => [
    id,
    fullname,
    shortname,
    dueDate,
    standard,
    testingPressure,
    workingPressure,
    typeOfCylinder,
    expansionRejection,
    weightRejection,
    lifeOfCylinder,
    intervalTesting,
    createdAt,
    updatedAt,
  ];
}
