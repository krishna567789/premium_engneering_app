import 'package:flutter/material.dart';
import '../widgets/home_components.dart';
import 'package:provider/provider.dart';
import '../provider/home_provider.dart';
import '../provider/home_state.dart';
import '../../certificate/screens/role1_edit_certificate_screen.dart';
import '../../certificate/screens/role2_edit_certificate_screen.dart';
import '../../certificate/screens/bank_detail_screen.dart';
import '../model/role1_certificate_list_model.dart';
import '../../certificate/screens/calculation_sheet_screen.dart';
import '../../../widgets/custom_widgets.dart';

String _formatDate(String? rawDate) {
  if (rawDate == null || rawDate.isEmpty || rawDate == "---") return "---";
  try {
    DateTime parsed = DateTime.parse(rawDate);
    return "${parsed.day.toString().padLeft(2, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.year}";
  } catch (e) {
    return rawDate;
  }
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

      // If one part is text (Month) and the other is numeric (Year)
      if (p1IsAlpha && !p2IsAlpha) {
        return "$p1-$p2"; // e.g. April-2026 -> perfect
      } else if (!p1IsAlpha && p2IsAlpha) {
        return "$p2-$p1"; // e.g. 2026-April -> flip to April-2026
      }

      // If both are numbers (MM-YYYY or YYYY-MM)
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

    // Fallback standard parse if it's a full DateTime string (YYYY-MM-DD)
    DateTime parsed = DateTime.parse(raw);
    return "${months[parsed.month - 1]}-${parsed.year}";
  } catch (e) {
    return raw;
  }
}

class Role1Table extends StatelessWidget {
  final String role;
  const Role1Table({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        final state = homeProvider.state;
        List<CertificateData> certificates =
            state.role1CertificateListData?.role1certificateList ?? [];

        if (state.searchQuery.isNotEmpty) {
          final query = state.searchQuery.toLowerCase();
          certificates = certificates.where((cert) {
            return (cert.certificateNo?.toLowerCase().contains(query) ??
                    false) ||
                (cert.cNo?.toLowerCase().contains(query) ?? false) ||
                (cert.dealerName?.toLowerCase().contains(query) ?? false) ||
                (cert.vehicleNumber?.toLowerCase().contains(query) ?? false) ||
                (cert.displayNumber?.toLowerCase().contains(query) ?? false) ||
                (cert.mobile?.toLowerCase().contains(query) ?? false);
          }).toList();
        }

        print("🏗️ BUILDING Role1Table WITH ${certificates.length} ITEMS");

        if (state.role1CertificateListStatus == HomeStatus.loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.role1CertificateListStatus == HomeStatus.error) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Error: ${state.errorMessage}",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (certificates.isEmpty &&
            state.role1CertificateListStatus == HomeStatus.success) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("No certificates found"),
            ),
          );
        }

        return DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFF555C8E)),
          headingTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          columnSpacing: 15,
          horizontalMargin: 15,
          dataRowMinHeight: 75,
          dataRowMaxHeight: 75,
          border: TableBorder.all(color: Colors.blue.shade200),
          columns: const [
            DataColumn(label: HomeSortHeader(label: "Sr.no")),
            DataColumn(label: HomeSortHeader(label: "Certificate No.")),
            DataColumn(label: HomeSortHeader(label: "Dealer")),
            DataColumn(label: HomeSortHeader(label: "Vehicle/Cascade No")),
            // DataColumn(label: HomeSortHeader(label: "Cyl.No")),
            DataColumn(label: HomeSortHeader(label: "Mfg. Date")),
            DataColumn(label: HomeSortHeader(label: "Product")),
            DataColumn(label: HomeSortHeader(label: "P.Status")),
            DataColumn(label: HomeSortHeader(label: "Pending Amount")),
            DataColumn(label: HomeSortHeader(label: "Mode of Payment")),
            DataColumn(label: HomeSortHeader(label: "Action")),
          ],
          rows: List.generate(
            certificates.length,
            (index) => _buildRow(context, index + 1, certificates[index]),
          ),
        );
      },
    );
  }

  DataRow _buildRow(BuildContext context, int index, CertificateData cert) {
    Color rowColor = const Color(0xFF2D3142); // Sophisticated dark blue-grey
    bool isStatusCompleted = cert.ptStatus == 'PC';
    TextStyle cellStyle = TextStyle(fontSize: 11, color: rowColor);

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
        // DataCell(
        //   Center(child: Text(cert.cylinderSerialNo ?? "---", style: cellStyle)),
        // ),
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
              isStatusCompleted
                  ? "No Pending"
                  : (cert.pendingAmount != null ? '₹ ${cert.pendingAmount}' : "₹ 0"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isStatusCompleted
                    ? const Color(0xFF555C8E)
                    : const Color(0xFF757575),
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              cert.ptModeStatus == 'C'
                  ? "Credit"
                  : (cert.ptModeStatus == 'R' ? "Cash" : "Pending"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: cert.ptModeStatus == 'R' || cert.ptModeStatus == 'C'
                    ? const Color(0xFF555C8E)
                    : const Color(0xFF757575),
              ),
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
                        pendingAmount: cert.pendingAmount?.toString(),
                        totalAmount: cert.paymentAmount?.toString(),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.account_balance,
                    color: const Color(0xFF555C8E), // Consistent theme color
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
                    color: const Color(0xFF555C8E), // Consistent theme color
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
  const Role2Table({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final state = provider.state;
        List<CertificateData> certificates =
            state.role2CertificateListData?.role1certificateList ?? [];

        if (state.searchQuery.isNotEmpty) {
          final query = state.searchQuery.toLowerCase();
          certificates = certificates.where((cert) {
            return (cert.certificateNo?.toLowerCase().contains(query) ??
                    false) ||
                (cert.cNo?.toLowerCase().contains(query) ?? false) ||
                (cert.dealerName?.toLowerCase().contains(query) ?? false) ||
                (cert.vehicleNumber?.toLowerCase().contains(query) ?? false) ||
                (cert.displayNumber?.toLowerCase().contains(query) ?? false) ||
                (cert.mobile?.toLowerCase().contains(query) ?? false);
          }).toList();
        }
        if (state.role2CertificateListStatus == HomeStatus.loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (certificates.isEmpty &&
            state.role2CertificateListStatus == HomeStatus.success) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("No Data Found"),
            ),
          );
        }

        return DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFF555C8E)),
          headingTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          columnSpacing: 15,
          horizontalMargin: 15,
          dataRowMinHeight: 75,
          dataRowMaxHeight: 75,
          border: TableBorder.all(color: Colors.blue.shade200),
          columns: const [
            DataColumn(label: HomeSortHeader(label: "Sr.no")),
            DataColumn(label: HomeSortHeader(label: "Certificate No")),
            DataColumn(label: HomeSortHeader(label: "Dealer")),
            DataColumn(label: HomeSortHeader(label: "Vehicle/Cascade No")),
            DataColumn(label: HomeSortHeader(label: "Cyl.No")),
            DataColumn(label: HomeSortHeader(label: "T.Date")),
            DataColumn(label: HomeSortHeader(label: "D.Date")),
            DataColumn(label: HomeSortHeader(label: "Product")),
            DataColumn(label: HomeSortHeader(label: "F.Status")),
            DataColumn(label: HomeSortHeader(label: "P.Status")),
            DataColumn(label: HomeSortHeader(label: "Pending Amount")),
            DataColumn(label: HomeSortHeader(label: "Mode of Payment")),
            DataColumn(label: HomeSortHeader(label: "Action")),
          ],
          rows: List.generate(
            certificates.length,
            (index) => _buildRow(context, index + 1, certificates[index]),
          ),
        );
      },
    );
  }

  DataRow _buildRow(BuildContext context, int index, CertificateData cert) {
    bool isStatusCompleted = cert.ptStatus == 'PC';

    Color rowColor;
    if (cert.status == 1) {
      rowColor = Colors.red;
    } else if (cert.status == 2) {
      rowColor = Colors.green;
    } else if (cert.status == 3) {
      rowColor = Colors.blue;
    } else {
      rowColor = const Color(0xFF2D3142);
    }

    TextStyle cellStyle = TextStyle(fontSize: 11, color: rowColor);

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
              color: rowColor,
            ),
          ),
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
              isStatusCompleted
                  ? "No Pending"
                  : (cert.pendingAmount != null ? '₹ ${cert.pendingAmount}' : "₹ 0"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isStatusCompleted
                    ? const Color(0xFF555C8E)
                    : rowColor,
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              cert.ptModeStatus == 'C'
                  ? "Credit"
                  : (cert.ptModeStatus == 'R' ? "Cash" : "Pending"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: cert.ptModeStatus == 'R' || cert.ptModeStatus == 'C'
                    ? const Color(0xFF555C8E)
                    : rowColor,
              ),
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

                          // Call update print status API
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
                            Navigator.pop(context); // Close loading dialog
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
                          color: const Color(0xFF555C8E),
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
                    color: const Color(0xFF555C8E),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          Role2EditCertificateScreen(certificate: cert),
                    ),
                  ),
                  child: Icon(
                    Icons.edit_square,
                    color: const Color(0xFF555C8E),
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
  // Generic fallback for other product types
  return text
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase())
      .join('');
}
