class PaymentTransactionModel {
  final String status;
  final List<TransactionData> data;

  PaymentTransactionModel({required this.status, required this.data});

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionModel(
      status: json['status'] ?? '',
      data: (json['data'] as List?)
              ?.map((e) => TransactionData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TransactionData {
  final int id;
  final int cId;
  final String pMode;
  final dynamic rAmount;
  final String pAmount;
  final String collectDate;
  final String createdAt;

  TransactionData({
    required this.id,
    required this.cId,
    required this.pMode,
    required this.rAmount,
    required this.pAmount,
    required this.collectDate,
    required this.createdAt,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? "0") ?? 0,
      cId: json['c_id'] is int ? json['c_id'] : int.tryParse(json['c_id']?.toString() ?? "0") ?? 0,
      pMode: json['p_mode']?.toString() ?? '',
      rAmount: json['r_amount'],
      pAmount: json['p_amount']?.toString() ?? '0',
      collectDate: json['collect_date']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
