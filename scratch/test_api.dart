import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  var url = Uri.parse('https://pe.microcmd.com/API/check_edit_password.php');
  
  // Test 1: Multipart
  print('--- Test 1: Multipart ---');
  var request = http.MultipartRequest('POST', url);
  request.fields.addAll({
    'certificate_id': '2',
    'edit_password': '12345'
  });
  
  var response = await request.send();
  print('Status: ${response.statusCode}');
  print('Body: ${await response.stream.bytesToString()}');
  
  // Test 2: Form URL Encoded
  print('\n--- Test 2: Form URL Encoded ---');
  var res = await http.post(url, body: {
    'certificate_id': '2',
    'edit_password': '12345'
  });
  print('Status: ${res.statusCode}');
  print('Body: ${res.body}');
}
