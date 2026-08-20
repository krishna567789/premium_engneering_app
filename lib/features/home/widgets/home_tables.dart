import 'package:flutter/material.dart';
import '../widgets/home_components.dart';
import 'package:provider/provider.dart';
import '../provider/home_state.dart';
import '../provider/home_provider.dart';
import '../../certificate/screens/role1_edit_certificate_screen.dart';
import '../../certificate/screens/role2_edit_certificate_screen.dart';
import '../../certificate/screens/bank_detail_screen.dart';
import '../model/role1_certificate_list_model.dart';
import '../../certificate/screens/calculation_sheet_screen.dart';
import '../../../widgets/custom_widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String _formatDate(String? rawDate) {
  if (rawDate == null || rawDate.isEmpty || rawDate == "---") return "---";
  try {
    DateTime parsed = DateTime.parse(rawDate);
    return "${parsed.day.toString().padLeft(2, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.year}";
  } catch (e) {
    return rawDate;
  }
}

String _formatCurrency(String? amount) {
  if (amount == null || amount.isEmpty || amount == '---') return '₹ 0.00';
  final val = double.tryParse(amount);
  if (val != null) {
    return '₹ ${val.toStringAsFixed(2)}';
  }
  return '₹ $amount';
}

String _formatManufacturingDate(String? raw) {
  if (raw == null || raw.isEmpty || raw == "---") return "---";
  try {
    List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    final parts = raw.split('-');
    if (parts.length == 2) {
      String p1 = parts[0].trim();
      String p2 = parts[1].trim();

      bool p1IsAlpha = RegExp(r'[a-zA-Z]').hasMatch(p1);
      bool p2IsAlpha = RegExp(r'[a-zA-Z]').hasMatch(p2);

      if (p1IsAlpha && !p2IsAlpha) {
        return "$p1-$p2";
      } else if (!p1IsAlpha && p2IsAlpha) {
        return "$p2-$p1";
      }

      if (!p1IsAlpha && !p2IsAlpha) {
        int num1 = int.parse(p1);
        int num2 = int.parse(p2);
        if (num1 <= 12 && num2 > 12) {
          return "${months[num1 - 1]}-$num2";
        } else if (num2 <= 12 && num1 > 12) {
          return "${months[num2 - 1]}-$num1";
        }
      }
    }

    DateTime parsed = DateTime.parse(raw);
    return "${months[parsed.month - 1]}-${parsed.year}";
  } catch (e) {
    return raw;
  }
}

class Role1Table extends StatelessWidget {
  final String role;
  final List<CertificateData> certificates;
  final HomeStatus status;
  final String errorMessage;

  const Role1Table({
    super.key,
    required this.role,
    required this.certificates,
    required this.status,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (status == HomeStatus.loading) {
      return _buildShimmerLoading();
    }

    if (status == HomeStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Error: $errorMessage",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (certificates.isEmpty && status == HomeStatus.success) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("No certificates found"),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary),
        headingTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        columnSpacing: 10,
        horizontalMargin: 10,
        dataRowMinHeight: 60,
        dataRowMaxHeight: 60,
        border: TableBorder.all(color: theme.dividerColor),
        columns: const [
          DataColumn(label: HomeSortHeader(label: "Sr.no")),
          DataColumn(label: HomeSortHeader(label: "Certificate No.")),
          DataColumn(label: HomeSortHeader(label: "Dealer")),
          DataColumn(label: HomeSortHeader(label: "Vehicle/Cascade No")),
          DataColumn(label: HomeSortHeader(label: "Mfg. Date")),
          DataColumn(label: HomeSortHeader(label: "Product")),
          DataColumn(label: HomeSortHeader(label: "Certificate Status")),
          DataColumn(
            label: HomeSortHeader(
              label: "Due\nAmount",
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          DataColumn(label: HomeSortHeader(label: "Action")),
        ],
        rows: List.generate(
          certificates.length,
          (index) => _buildRow(context, index + 1, certificates[index]),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.all(10.0),
          child: ShimmerLoading(
            isLoading: true,
            child: Row(
              children: [
                const ShimmerPlaceholder(width: 40, height: 40),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerPlaceholder(width: 150, height: 15),
                      const SizedBox(height: 8),
                      ShimmerPlaceholder(width: 100, height: 12),
                    ],
                  ),
                ),
                const ShimmerPlaceholder(
                  width: 60,
                  height: 25,
                  borderRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, int index, CertificateData cert) {
    final theme = Theme.of(context);
    bool isStatusCompleted = cert.payStatus == 'PC' || cert.payStatus == 'C';
    TextStyle cellStyle = TextStyle(
      fontSize: 14,
      color: theme.textTheme.bodyMedium?.color,
      fontWeight: FontWeight.bold,
    );

    print('================>payment_amount: ${cert.paymentAmount}');

    return DataRow(
      cells: [
        DataCell(Center(child: Text(index.toString(), style: cellStyle))),
        DataCell(
          Center(
            child: Text(
              cert.certificateNo ??
                  (cert.cNo != null ? "demo\n${cert.cNo}" : "---"),
              textAlign: TextAlign.center,

              style: cellStyle,
            ),
          ),
        ),
        DataCell(
          Center(child: Text(cert.dealerName ?? "---", style: cellStyle)),
        ),
        DataCell(
          Center(
            child: Text(
              cert.displayNumber ?? cert.vehicleNumber ?? "---",
              textAlign: TextAlign.center,
              style: cellStyle,
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              _formatManufacturingDate(cert.manufacturingDate),
              textAlign: TextAlign.center,
              style: cellStyle,
            ),
          ),
        ),
        DataCell(
          Center(child: Text(_getInitials(cert.productType), style: cellStyle)),
        ),
        DataCell(
          Center(
            child: HomeStatusPill(
              text: isStatusCompleted ? "Completed" : "Pending",
              isSuccess: isStatusCompleted,
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              _formatCurrency(cert.paymentAmount ?? '0'),
              textAlign: TextAlign.center,
              style: cellStyle,
            ),
          ),
        ),
        DataCell(
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => BankDetailScreen(
                        certNo: cert.certificateNo ?? "",
                        holderName: cert.productType ?? cert.dealerName ?? "",
                        id: cert.id?.toString(),
                        dealerId: cert.dealerId?.toString(),
                        pendingAmount: cert.pendingAmtInOffices?.toString(),
                        totalAmount: cert.paymentAmount?.toString(),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.account_balance,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          Role1EditCertificateScreen(certificate: cert),
                    ),
                  ),
                  child: Icon(
                    Icons.edit_square,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Role2Table extends StatelessWidget {
  final String role;
  final List<CertificateData> certificates;
  final HomeStatus status;
  final String errorMessage;

  const Role2Table({
    super.key,
    required this.role,
    required this.certificates,
    required this.status,
    required this.errorMessage,
  });

  void _showEditPasswordDialog(BuildContext context, CertificateData cert) {
    final TextEditingController passwordController = TextEditingController();
    bool isLoading = false;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GlassDialog(
              child: Container(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Enter Edit Password",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      hintText: "Password",
                      controller: passwordController,
                      // isPassword: true,
                      prefixIcon: Icons.lock,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              side: BorderSide(color: theme.dividerColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    print('status-------------$cert.status');
                                    if (passwordController.text.isEmpty) {
                                      CustomToast.error(
                                        context,
                                        "Please enter password",
                                        top: true,
                                      );
                                      return;
                                    }
                                    setState(() {
                                      isLoading = true;
                                    });

                                    try {
                                      var request = http.MultipartRequest(
                                        'POST',
                                        Uri.parse(
                                          'https://pe.microcmd.com/API/check_edit_password.php',
                                        ),
                                      );
                                      request.fields.addAll({
                                        'certificate_id':
                                            cert.id?.toString() ?? '',
                                        'edit_password':
                                            passwordController.text,
                                      });

                                      print('--- API REQUEST ---');
                                      print('URL: ${request.url}');
                                      print('Fields: ${request.fields}');

                                      http.StreamedResponse response =
                                          await request.send();

                                      if (response.statusCode == 200) {
                                        String resBody = await response.stream
                                            .bytesToString();

                                        print('--- API RESPONSE ---');
                                        print(
                                          'Status Code: ${response.statusCode}',
                                        );
                                        print('Body: $resBody');

                                        bool isSuccess = false;
                                        String errorMessage =
                                            "Invalid password";

                                        try {
                                          var data = jsonDecode(resBody);
                                          if (data['status'] == true ||
                                              data['status'] == 1 ||
                                              data['status'] == 'true' ||
                                              data['status'] == 'success' ||
                                              data['success'] == true) {
                                            isSuccess = true;
                                          } else {
                                            errorMessage =
                                                data['message'] ??
                                                "Invalid password";
                                          }
                                        } catch (e) {
                                          if (resBody.toLowerCase().contains(
                                            "success",
                                          )) {
                                            isSuccess = true;
                                          }
                                        }

                                        if (isSuccess) {
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    Role2EditCertificateScreen(
                                                      certificate: cert,
                                                    ),
                                              ),
                                            );
                                          }
                                        } else {
                                          if (context.mounted) {
                                            CustomToast.error(
                                              context,
                                              errorMessage,
                                              top: true,
                                            );
                                          }
                                        }
                                      } else {
                                        if (context.mounted) {
                                          CustomToast.error(
                                            context,
                                            "Error: ${response.reasonPhrase}",
                                            top: true,
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        CustomToast.error(
                                          context,
                                          "An error occurred",
                                          top: true,
                                        );
                                      }
                                    } finally {
                                      if (context.mounted) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Submit",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // [15:08, 10/08/2026] Niraj Sir: Achha tik hai
  // [15:09, 10/08/2026] Niraj Sir: Tab tak ke liye ek pop create kar do jisme
  // Edit password puchhe ga
  // [15:10, 10/08/2026] Niraj Sir: Or edit button ka icon de kar ume ek button bhi de do
  // [15:10, 10/08/2026] Niraj Sir: Submit me me ek API chali gi ju password check kare ga ki Correct hai ki nhi
  // [15:10, 10/08/2026] Niraj Sir: Itna kaam karo tak tak me khana kha lo
  // [15:11, 10/08/2026] Niraj Sir: Phir api se karta ho
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (status == HomeStatus.loading) {
      return _buildShimmerLoading();
    }

    if (certificates.isEmpty && status == HomeStatus.success) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("No Data Found"),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary),
        headingTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        columnSpacing: 15,
        horizontalMargin: 15,
        dataRowMinHeight: 75,
        dataRowMaxHeight: 75,
        border: TableBorder.all(color: theme.dividerColor),
        columns: const [
          DataColumn(label: HomeSortHeader(label: "Sr.no")),
          DataColumn(label: HomeSortHeader(label: "Certificate No")),
          DataColumn(label: HomeSortHeader(label: "Dealer")),
          DataColumn(label: HomeSortHeader(label: "Vehicle/Cascade No")),
          DataColumn(label: HomeSortHeader(label: "Cyl.No")),
          DataColumn(label: HomeSortHeader(label: "T.Date")),
          DataColumn(label: HomeSortHeader(label: "D.Date")),
          DataColumn(label: HomeSortHeader(label: "Product")),
          DataColumn(label: HomeSortHeader(label: "Certificate Status")),
          DataColumn(
            label: HomeSortHeader(
              label: "Due\nAmount",
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          DataColumn(label: HomeSortHeader(label: "Action")),
        ],
        rows: List.generate(
          certificates.length,
          (index) => _buildRow(context, index + 1, certificates[index]),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.all(15.0),
          child: ShimmerLoading(
            isLoading: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ShimmerPlaceholder(width: 120, height: 18),
                    const ShimmerPlaceholder(
                      width: 80,
                      height: 22,
                      borderRadius: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const ShimmerPlaceholder(width: double.infinity, height: 14),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const ShimmerPlaceholder(width: 100, height: 12),
                    const SizedBox(width: 20),
                    const ShimmerPlaceholder(width: 100, height: 12),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, int index, CertificateData cert) {
    final theme = Theme.of(context);
    bool isStatusCompleted = cert.ptStatus == 'PC';

    Color statusColor;
    if (cert.status == 1) {
      statusColor = Colors.red;
    } else if (cert.status == 2) {
      statusColor = Colors.green;
    } else if (cert.status == 3) {
      statusColor = theme.colorScheme.primary;
    } else {
      statusColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    }

    TextStyle cellStyle = TextStyle(
      fontSize: 12,
      color: theme.textTheme.bodyMedium?.color,
      fontWeight: FontWeight.bold,
    );

    String fStatusText = cert.status == 1
        ? "Pending"
        : (cert.status == 2
              ? "Completed"
              : (cert.status == 3 ? "Printed" : "Pending"));
    bool fStatusSuccess = cert.status == 2 || cert.status == 3;

    return DataRow(
      cells: [
        DataCell(Center(child: Text(index.toString(), style: cellStyle))),
        DataCell(
          Center(
            child: Text(
              cert.certificateNo ?? "---",
              textAlign: TextAlign.center,
              style: cellStyle,
            ),
          ),
        ),
        DataCell(
          Center(child: Text(cert.dealerName ?? "---", style: cellStyle)),
        ),
        DataCell(
          Center(
            child: Text(
              cert.displayNumber ?? cert.vehicleNumber ?? "---",
              textAlign: TextAlign.center,
              style: cellStyle,
            ),
          ),
        ),
        DataCell(
          Center(child: Text(cert.cylinderSerialNo ?? "---", style: cellStyle)),
        ),
        DataCell(
          Center(
            child: Text(
              _formatDate(cert.testDate),
              textAlign: TextAlign.center,
              style: cellStyle,
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              _formatDate(cert.nextTestDate),
              textAlign: TextAlign.center,
              style: cellStyle,
            ),
          ),
        ),
        DataCell(
          Center(child: Text(_getInitials(cert.productType), style: cellStyle)),
        ),
        DataCell(
          Center(
            child: HomeStatusPill(
              text: fStatusText,
              isSuccess: fStatusSuccess,
              color: statusColor,
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              isStatusCompleted
                  ? "No Pending"
                  : _formatCurrency(
                      cert.paymentAmount ?? cert.pendingAmount ?? "0",
                    ),
              textAlign: TextAlign.center,
              style: cellStyle,
            ),
          ),
        ),
        DataCell(
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                cert.status == 2 || cert.status == 3
                    ? GestureDetector(
                        onTap: () async {
                          if (cert.dealerName == null ||
                              cert.dealerName!.isEmpty ||
                              cert.dealerName == "---") {
                            CustomToast.error(
                              context,
                              "Please update the dealer name\nWithout dealer print cannot perform",
                            );
                            return;
                          }
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          final homeProvider = context.read<HomeProvider>();
                          await homeProvider.updatePrintStatus(
                            cert.id?.toString() ?? "",
                          );

                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CalculationSheetScreen(certificate: cert),
                              ),
                            );
                          }
                        },
                        child: Icon(
                          Icons.print_outlined,
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                      )
                    : const Text(
                        "---",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => BankDetailScreen(
                        certNo: cert.certificateNo ?? "",
                        holderName: cert.productType ?? cert.dealerName ?? "",
                        id: cert.id?.toString(),
                        dealerId: cert.dealerId?.toString(),
                        pendingAmount: cert.pendingAmount?.toString(),
                        totalAmount: cert.paymentAmount?.toString(),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.account_balance,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    print('status-------------${cert.status}');
                    if (cert.status == 2 || cert.status == 3) {
                      _showEditPasswordDialog(context, cert);
                      print('status-------------$cert.status');
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              Role2EditCertificateScreen(certificate: cert),
                        ),
                      );
                    }
                  },
                  child: Icon(
                    Icons.edit_square,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _getInitials(String? text) {
  if (text == null || text.isEmpty) return "---";
  String clean = text.toLowerCase().trim();
  if (clean.contains("compress") &&
      clean.contains("natural") &&
      clean.contains("gas")) {
    return "CNG";
  }
  return text
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase())
      .join('');
}
