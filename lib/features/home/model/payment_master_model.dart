class PaymentMasterModel {
  final String status;
  final List<PaymentMode> data;

  PaymentMasterModel({required this.status, required this.data});

  factory PaymentMasterModel.fromJson(Map<String, dynamic> json) {
    return PaymentMasterModel(
      status: json['status'] ?? '',
      data: (json['data'] as List?)
              ?.map((e) => PaymentMode.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PaymentMode {
  final int id;
  final String pName;
  final String createdAt;

  PaymentMode({
    required this.id,
    required this.pName,
    required this.createdAt,
  });

  factory PaymentMode.fromJson(Map<String, dynamic> json) {
    return PaymentMode(
      id: json['id'] ?? 0,
      pName: json['p_name'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
