import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:premium_engneering_app/features/home/provider/home_provider.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../home/model/role1_certificate_list_model.dart';
import '../../../core/theme.dart';

class CalculationSheetScreen extends StatelessWidget {
  final CertificateData certificate;

  const CalculationSheetScreen({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Calculation Sheet",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 10),
            Center(
              child: Text(
                "Calculation Sheet",
                style: GoogleFonts.lobster(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Sr. No.: ${certificate.certificateNo ?? '---'}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 15),
            _buildInfoTable(),
            const SizedBox(height: 20),
            const Text(
              "Testing Details:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildTestingDetailsTable(),
            const SizedBox(height: 15),
            _buildThicknessTable(),
            const SizedBox(height: 20),
            const Text(
              "Hydrostatic Stretch Test Result:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildHydrostaticTable(),
            const SizedBox(height: 20),
            _buildPhotoSection(),
            const SizedBox(height: 20),
            _buildRemarksSection(),
            const SizedBox(height: 20),
            _buildSignatureSection(),
            const SizedBox(height: 30),
            Center(
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () => _generatePdf(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              "assets/images/gas_logo.webp",
              width: 80,
              height: 80,
              fit: BoxFit.fill,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "PREMIUM",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  "HYDRO ENGINEERING",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "CNG CYLINDER TESTING SERVICES",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoTable() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final val = certificate.cylinderMake ?? "---";
        final makes = provider.state.cylinderMakeData?.data ?? [];
        String cylinderMakeName = val;
        try {
          final match = makes.firstWhere(
            (e) => e.id.toString() == val || e.fullname == val,
          );
          cylinderMakeName = match.fullname ?? val;
        } catch (_) {}

        final vVal = certificate.vehicalType ?? "---";
        final vTypes = provider.state.vehicleTypeData?.data ?? [];
        String vehicleTypeName = vVal;
        try {
          final vMatch = vTypes.firstWhere(
            (e) => e.id.toString() == vVal || e.vehicleName == vVal,
          );
          vehicleTypeName = vMatch.vehicleName ?? vVal;
        } catch (_) {}

        return Table(
          border: TableBorder.all(color: Colors.black),
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(1.2),
            3: FlexColumnWidth(1.5),
          },
          children: [
            _buildTableRow([
              "Dealer Name",
              certificate.dealerName ?? "---",
              "Dealer Mobile Number",
              certificate.mobile ?? "---",
            ]),
            _buildTableRow([
              "Vehicle Type",
              vehicleTypeName,
              "Test Date",
              _formatDate(certificate.testDate),
            ]),
            _buildTableRow([
              "Vehicle Number",
              certificate.vehicleNumber ?? "---",
              "Next Test Due Date",
              _formatDate(certificate.nextTestDate),
            ]),
            _buildTableRow([
              "Product Type",
              certificate.productType ?? "---",
              "Cylinder Specification",
              certificate.specification ?? "---",
            ]),
            _buildTableRow([
              "Cylinder Make",
              cylinderMakeName,
              "Manufacturing Date",
              _formatDate(certificate.manufacturingDate),
            ]),
            _buildTableRow([
              "Filling Permission Number",
              certificate.cceFillingPermissionNo ?? "---",
              "Filling P. Date",
              _formatDate(certificate.fillingPermissionDate),
            ]),
          ],
        );
      },
    );
  }

  TableRow _buildTableRow(List<String> cells) {
    return TableRow(
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(cell, style: const TextStyle(fontSize: 12)),
        );
      }).toList(),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == "---") {
      return "---";
    }
    try {
      // Handle cases like "2023-10-25" or "2023-10-25 10:20:30"
      if (dateStr.contains("-")) {
        final parts = dateStr.split(" ")[0].split("-");
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            // YYYY-MM-DD
            return "${parts[2]}-${parts[1]}-${parts[0]}";
          } else if (parts[2].length == 4) {
            // DD-MM-YYYY
            return dateStr.split(" ")[0];
          }
        } else if (parts.length == 2) {
          // Handle manufacturing date like "04-2020" or "2020-04"
          if (parts[0].length == 4) {
            return "${parts[1]}-${parts[0]}";
          }
          return dateStr;
        }
      }
    } catch (_) {}
    return dateStr;
  }

  String _getInspectionStatus(dynamic val) {
    if (val == null || val == "") return "OK";
    final s = val.toString().trim().toUpperCase();
    if (s == "0" || s == "OK" || s == "PASS") return "OK";
    if (s == "1" || s == "NOT OK" || s == "FAIL" || s == "REJECTED")
      return "Not OK";
    return s;
  }

  Widget _buildTestingDetailsTable() {
    return Table(
      border: TableBorder.all(color: Colors.black),
      columnWidths: const {
        0: FlexColumnWidth(1.2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.2),
        3: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow([
          "Valve Inspection",
          _getInspectionStatus(certificate.valveInspection),
          "Original Tare Weight",
          certificate.originalTareWeight ?? "---",
        ]),
        _buildTableRow([
          "Visual Inspection",
          _getInspectionStatus(certificate.visualInspection),
          "Actual Weight",
          certificate.actualWeight ?? "---",
        ]),
        _buildTableRow([
          "Cylinder Threading",
          _getInspectionStatus(certificate.cylinderThreading),
          "Loss of Weight",
          certificate.lossOfWeight ?? "0.00",
        ]),
        _buildTableRow([
          "Internal Inspection",
          _getInspectionStatus(certificate.internalInspection),
          "Loss of Weight %",
          certificate.lossOfWeightPercentage ?? "0.00",
        ]),
      ],
    );
  }

  Widget _buildThicknessTable() {
    return Column(
      children: [
        Table(
          border: TableBorder.all(color: Colors.black),
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(1.5),
          },
          children: [
            _buildTableRow([
              "Painting",
              _getInspectionStatus(certificate.painting),
            ]),
            _buildTableRow([
              "Dia of Cylinder",
              certificate.dieOfCylinder ?? "---",
            ]),
          ],
        ),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: Colors.black),
          children: [
            const TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Cylinder Wall Thickness",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Minimum Calculated",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Minimum Observed",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            _buildTableRowCenter([
              "Shell",
              certificate.shellMinCalThick ?? "---",
              certificate.shellObsThickMin ?? "---",
            ]),
            _buildTableRowCenter([
              "Bottom Centre",
              certificate.bottomMinCalThick ?? "---",
              certificate.bottomObsThickMin ?? "---",
            ]),
          ],
        ),
      ],
    );
  }

  TableRow _buildTableRowCenter(List<String> cells) {
    return TableRow(
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(cell, style: const TextStyle(fontSize: 12)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHydrostaticTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.black),
        defaultColumnWidth: const FixedColumnWidth(80),
        children: [
          const TableRow(
            children: [
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Center(
                  child: Text(
                    "Water Capacity",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Center(
                  child: Text(
                    "Working Pressure",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Center(
                  child: Text(
                    "Test Pressure",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Center(
                  child: Text(
                    "Initial Expansion",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Center(
                  child: Text(
                    "Total Expansion",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Center(
                  child: Text(
                    "Permanent Expansion",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Center(
                  child: Text(
                    "Permanent %",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Center(
                  child: Text(
                    "Result",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          _buildTableRowCenter([
            certificate.waterCapacity ?? "---",
            certificate.workingPressure ?? "---",
            certificate.testPressure ?? "---",
            certificate.initialExpansion ?? "---",
            certificate.totalExpansion ?? "---",
            certificate.permanentExpansion ?? "---",
            certificate.permanentExpansionPercentage ?? "---",
            certificate.result ?? "---",
          ]),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Table(
      border: TableBorder.all(color: Colors.black),
      children: [
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "Number Plate Photo",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "Making Cylinder Neck Photo",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            _buildPhotoImage(certificate.photoNumberPlate),
            _buildPhotoImage(certificate.photoMarkingDetails),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoImage(String? url) {
    String? fullUrl;
    if (url != null && url.isNotEmpty) {
      if (url.startsWith("http")) {
        fullUrl = url;
      } else {
        fullUrl = "https://pe.microcmd.com/API/uploads/$url";
      }
    }

    return Container(
      height: 150,
      padding: const EdgeInsets.all(8.0),
      child: fullUrl != null
          ? Image.network(
              fullUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey,
              ),
            )
          : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
    );
  }

  Widget _buildRemarksSection() {
    return Table(
      border: TableBorder.all(color: Colors.black),
      columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(3)},
      children: [
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Center(
                child: Text(
                  "Remarks",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(certificate.remark ?? "---"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignatureSection() {
    return Table(
      border: TableBorder.all(color: Colors.black),
      children: const [
        TableRow(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
              child: Center(
                child: Text(
                  "Test done by:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
              child: Center(
                child: Text(
                  "Authorized Signatory",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _generatePdf(BuildContext context) async {
    final provider = context.read<HomeProvider>();
    final val = certificate.cylinderMake ?? "---";
    final makes = provider.state.cylinderMakeData?.data ?? [];
    String cylinderMakeName = val;
    try {
      final match = makes.firstWhere(
        (e) => e.id.toString() == val || e.fullname == val,
      );
      cylinderMakeName = match.fullname ?? val;
    } catch (_) {}

    final vVal = certificate.vehicalType ?? "---";
    final vTypes = provider.state.vehicleTypeData?.data ?? [];
    String vehicleTypeName = vVal;
    try {
      final vMatch = vTypes.firstWhere(
        (e) => e.id.toString() == vVal || e.vehicleName == vVal,
      );
      vehicleTypeName = vMatch.vehicleName ?? vVal;
    } catch (_) {}

    final pdf = pw.Document();

    final primaryColor = Theme.of(context).colorScheme.primary;
    final pdfPrimary = PdfColor.fromInt(primaryColor.value);

    // Pre-fetch images
    Uint8List? logoBytes;
    try {
      final ByteData data = await rootBundle.load(
        'assets/images/gas_logo.webp',
      );
      logoBytes = data.buffer.asUint8List();
    } catch (e) {
      debugPrint("Error loading logo: $e");
    }

    Uint8List? plateBytes;
    Uint8List? neckBytes;

    if (certificate.photoNumberPlate != null &&
        certificate.photoNumberPlate!.isNotEmpty) {
      final url = certificate.photoNumberPlate!.startsWith("http")
          ? certificate.photoNumberPlate!
          : "https://pe.microcmd.com/API/uploads/${certificate.photoNumberPlate}";
      plateBytes = await _fetchImageBytes(url);
    }

    if (certificate.photoMarkingDetails != null &&
        certificate.photoMarkingDetails!.isNotEmpty) {
      final url = certificate.photoMarkingDetails!.startsWith("http")
          ? certificate.photoMarkingDetails!
          : "https://pe.microcmd.com/API/uploads/${certificate.photoMarkingDetails}";
      neckBytes = await _fetchImageBytes(url);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            // Header with Logo
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                if (logoBytes != null)
                  pw.Image(
                    pw.MemoryImage(logoBytes),
                    width: 70,
                    height: 70,
                    fit: pw.BoxFit.fill,
                  ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "PREMIUM",
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: pdfPrimary,
                      ),
                    ),
                    pw.Text(
                      "HYDRO ENGINEERING",
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: pdfPrimary,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      "CNG CYLINDER TESTING SERVICES",
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                "Calculation Sheet",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                  color: pdfPrimary,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              "Sr. No.: ${certificate.certificateNo ?? '---'}",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            _buildPdfTable(cylinderMakeName, vehicleTypeName),
            pw.SizedBox(height: 15),
            pw.Text(
              "Testing Details:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            _buildPdfTestingTable(),
            pw.SizedBox(height: 10),
            _buildPdfThicknessTable(),
            pw.SizedBox(height: 15),
            pw.Text(
              "Hydrostatic Stretch Test Result:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            _buildPdfHydrostaticTable(),
            pw.SizedBox(height: 15),
            pw.Text(
              "Certificate Photos:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            _buildPdfPhotoSection(plateBytes, neckBytes),
            pw.SizedBox(height: 15),
            pw.Text("Remarks: ${certificate.remark ?? '---'}"),
            pw.SizedBox(height: 30),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Test done by:",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  "Authorized Signatory",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPdfTable(String cylinderMakeName, String vehicleTypeName) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        _buildPdfTableRow([
          "Dealer Name",
          certificate.dealerName ?? "---",
          "Dealer Mobile",
          certificate.mobile ?? "---",
        ]),
        _buildPdfTableRow([
          "Vehicle Type",
          vehicleTypeName,
          "Test Date",
          _formatDate(certificate.testDate),
        ]),
        _buildPdfTableRow([
          "Vehicle Number",
          certificate.vehicleNumber ?? "---",
          "Next Test Due",
          _formatDate(certificate.nextTestDate),
        ]),
        _buildPdfTableRow([
          "Product Type",
          certificate.productType ?? "---",
          "Cylinder Spec",
          certificate.specification ?? "---",
        ]),
        _buildPdfTableRow([
          "Cylinder Number",
          certificate.cylinderSerialNo ?? "---",
          "Last Test Date",
          _formatDate(certificate.lastTestDate),
        ]),
        _buildPdfTableRow([
          "Cylinder Make",
          cylinderMakeName,
          "Mfg. Date",
          _formatDate(certificate.manufacturingDate),
        ]),
      ],
    );
  }

  pw.TableRow _buildPdfTableRow(List<String> cells) {
    return pw.TableRow(
      children: cells
          .map(
            (cell) => pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(cell, style: const pw.TextStyle(fontSize: 10)),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _buildPdfTestingTable() {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        _buildPdfTableRow([
          "Valve Insp.",
          _getInspectionStatus(certificate.valveInspection),
          "Orig. Tare Wt.",
          certificate.originalTareWeight ?? "---",
        ]),
        _buildPdfTableRow([
          "Visual Insp.",
          _getInspectionStatus(certificate.visualInspection),
          "Actual Wt.",
          certificate.actualWeight ?? "---",
        ]),
        _buildPdfTableRow([
          "Cyl. Threading",
          _getInspectionStatus(certificate.cylinderThreading),
          "Loss of Wt.",
          certificate.lossOfWeight ?? "0.00",
        ]),
        _buildPdfTableRow([
          "Int. Insp.",
          _getInspectionStatus(certificate.internalInspection),
          "Loss of Wt. %",
          certificate.lossOfWeightPercentage ?? "0.00",
        ]),
      ],
    );
  }

  pw.Widget _buildPdfThicknessTable() {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                "Wall Thickness",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                "Min Calculated",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                "Min Observed",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        _buildPdfTableRowCenter([
          "Shell",
          certificate.shellMinCalThick ?? "---",
          certificate.shellObsThickMin ?? "---",
        ]),
        _buildPdfTableRowCenter([
          "Bottom Centre",
          certificate.bottomMinCalThick ?? "---",
          certificate.bottomObsThickMin ?? "---",
        ]),
      ],
    );
  }

  pw.TableRow _buildPdfTableRowCenter(List<String> cells) {
    return pw.TableRow(
      children: cells
          .map(
            (cell) => pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Center(
                child: pw.Text(cell, style: const pw.TextStyle(fontSize: 10)),
              ),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _buildPdfHydrostaticTable() {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children:
              [
                    "Water Cap.",
                    "Work Pres.",
                    "Test Pres.",
                    "Init Exp.",
                    "Total Exp.",
                    "Perm Exp.",
                    "Perm %",
                    "Result",
                  ]
                  .map(
                    (h) => pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Center(
                        child: pw.Text(
                          h,
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
        pw.TableRow(
          children:
              [
                    certificate.waterCapacity ?? "---",
                    certificate.workingPressure ?? "---",
                    certificate.testPressure ?? "---",
                    certificate.initialExpansion ?? "---",
                    certificate.totalExpansion ?? "---",
                    certificate.permanentExpansion ?? "---",
                    certificate.permanentExpansionPercentage ?? "---",
                    certificate.result ?? "---",
                  ]
                  .map(
                    (c) => pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Center(
                        child: pw.Text(
                          c,
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  pw.Widget _buildPdfPhotoSection(Uint8List? plate, Uint8List? neck) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Center(
                child: pw.Text(
                  "Number Plate Photo",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Center(
                child: pw.Text(
                  "Making Cylinder Neck Photo",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Container(
              height: 100,
              padding: const pw.EdgeInsets.all(5),
              child: pw.Center(
                child: plate != null
                    ? pw.Image(pw.MemoryImage(plate), fit: pw.BoxFit.contain)
                    : pw.Text(
                        "No Image",
                        style: const pw.TextStyle(fontSize: 8),
                      ),
              ),
            ),
            pw.Container(
              height: 100,
              padding: const pw.EdgeInsets.all(5),
              child: pw.Center(
                child: neck != null
                    ? pw.Image(pw.MemoryImage(neck), fit: pw.BoxFit.contain)
                    : pw.Text(
                        "No Image",
                        style: const pw.TextStyle(fontSize: 8),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<Uint8List?> _fetchImageBytes(String url) async {
    try {
      final response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.data != null) {
        return Uint8List.fromList(response.data!);
      }
    } catch (e) {
      debugPrint("Error fetching image: $e");
    }
    return null;
  }
}
