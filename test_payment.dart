import 'dart:convert';
import 'lib/features/home/model/role1_certificate_list_model.dart';

void main() {
  String jsonStr = '''{
    "status": "success",
    "certificateList": [
      {
        "id": 7,
        "admin_id": 25,
        "payment_amount": 500,
        "product_type": "Compress Natural Gas"
      },
      {
        "id": 8,
        "admin_id": 26,
        "Payment_amount": 1200,
        "product_type": "Oxygen"
      }
    ]
  }''';

  Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
  Role1CertificateListModel model = Role1CertificateListModel.fromJson(jsonMap);

  for (var cert in model.role1certificateList ?? []) {
    print("Certificate ID: " + cert.id.toString());
    print("cert.paymentAmount: " + cert.paymentAmount.toString());
    print("cert.Payment_amount: " + cert.Payment_amount.toString());
    print("----------------------------");
  }
}
