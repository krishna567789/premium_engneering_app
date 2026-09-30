import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:premium_engneering_app/features/home/provider/home_provider.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../home/model/role1_certificate_list_model.dart';
import '../../auth/data/auth_repository.dart';

class CalculationSheetScreen extends StatefulWidget {
  final CertificateData certificate;

  const CalculationSheetScreen({super.key, required this.certificate});

  @override
  State<CalculationSheetScreen> createState() => _CalculationSheetScreenState();
}

class _CalculationSheetScreenState extends State<CalculationSheetScreen> {
  String _userName = "";

  CertificateData get certificate => widget.certificate;

  String get _companyName => certificate.adminCompanyName ?? "";
  String get _tagline => certificate.tagline ?? "";
  String get _licenseName => certificate.licenseName ?? "";

  String? get _logoUrl {
    final logo = certificate.adminCompanyLogo;
    if (logo == null || logo.isEmpty) return null;
    print('----------logo---------');
    print('https://pe.microcmd.com/admin/uploads/$logo');
    print('-----------------------');
    return logo.startsWith("http")
        ? logo
        : "https://pe.microcmd.com/admin/uploads/admin_logo/$logo";
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authRepo = context.read<AuthRepository>();
      final name = await authRepo.getUserName();
      if (mounted) {
        setState(() {
          _userName = name ?? "";
        });
      }
    });
  }

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
            if (_shouldShowPhotos) ...[
              const SizedBox(height: 20),
              const Text(
                "Certificate Photos:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              _buildPhotoSection(),
            ],
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
    final logoUrl = _logoUrl;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: logoUrl != null
              ? Image.network(
                  logoUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    "assets/images/gas_logo.webp",
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                )
              : Image.asset(
                  "assets/images/gas_logo.webp",
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_companyName.isNotEmpty)
                Text(
                  _companyName.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.primary,
                    height: 1.15,
                  ),
                ),
              if (_tagline.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _tagline.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
              if (_licenseName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  "License Name: $_licenseName",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTable() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final val = certificate.cylinderMake ?? "---";
        final makes = provider.state.cylinderMakeData?.data ?? [];
        String cylinderMakeName =
            certificate.cylinderMakeName?.isNotEmpty == true
            ? certificate.cylinderMakeName!
            : val;
        if (cylinderMakeName == val) {
          try {
            final match = makes.firstWhere(
              (e) => e.id.toString() == val || e.fullname == val,
            );
            cylinderMakeName = match.fullname ?? val;
          } catch (_) {}
        }

        final vVal = certificate.vehicalType ?? "---";
        final vTypes = provider.state.vehicleTypeData?.data ?? [];
        String vehicleTypeName = certificate.vehicleTypeName?.isNotEmpty == true
            ? certificate.vehicleTypeName!
            : vVal;
        if (vehicleTypeName == vVal) {
          try {
            final vMatch = vTypes.firstWhere(
              (e) => e.id.toString() == vVal || e.vehicleName == vVal,
            );
            vehicleTypeName = vMatch.vehicleName ?? vVal;
          } catch (_) {}
        }

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
    if (s == "1" || s == "NOT OK" || s == "FAIL" || s == "REJECTED") {
      return "Not OK";
    }
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
                      "Observed Thickness",
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
                    "Permanent EXP. %",
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

  String? _formatImageUrl(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed == "null" || trimmed == "---") return null;
    if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
      return trimmed;
    }
    String path = trimmed;
    while (path.startsWith("/")) {
      path = path.substring(1);
    }
    if (path.startsWith("uploads/")) {
      path = path.substring("uploads/".length);
    }
    while (path.startsWith("/")) {
      path = path.substring(1);
    }
    return "https://pe.microcmd.com/API/uploads/$path";
  }

  bool get _shouldShowPhotos {
    final hasPlate = _formatImageUrl(certificate.photoNumberPlate) != null;
    final hasMarking = _formatImageUrl(certificate.photoMarkingDetails) != null;
    if (hasPlate || hasMarking) return true;

    final pType = (certificate.productType ?? '').toLowerCase().trim();
    return pType.contains('gas') ||
        pType.contains('cng') ||
        pType.contains('compress') ||
        certificate.productType == 'Compress Natural Gas';
  }

  Widget _buildPhotoImage(String? url) {
    final fullUrl = _formatImageUrl(url);

    return Container(
      height: 150,
      padding: const EdgeInsets.all(8.0),
      child: fullUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                fullUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Image not available",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey,
              ),
            ),
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
      children: [
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
              child: Center(
                child: Text(
                  _userName.isNotEmpty
                      ? "Test done by:\n$_userName"
                      : "Test done by:",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Padding(
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
    String cylinderMakeName = certificate.cylinderMakeName?.isNotEmpty == true
        ? certificate.cylinderMakeName!
        : val;
    if (cylinderMakeName == val) {
      try {
        final match = makes.firstWhere(
          (e) => e.id.toString() == val || e.fullname == val,
        );
        cylinderMakeName = match.fullname ?? val;
      } catch (_) {}
    }

    final vVal = certificate.vehicalType ?? "---";
    final vTypes = provider.state.vehicleTypeData?.data ?? [];
    String vehicleTypeName = certificate.vehicleTypeName?.isNotEmpty == true
        ? certificate.vehicleTypeName!
        : vVal;
    if (vehicleTypeName == vVal) {
      try {
        final vMatch = vTypes.firstWhere(
          (e) => e.id.toString() == vVal || e.vehicleName == vVal,
        );
        vehicleTypeName = vMatch.vehicleName ?? vVal;
      } catch (_) {}
    }

    final pdf = pw.Document();

    final primaryColor = Theme.of(context).colorScheme.primary;
    final pdfPrimary = PdfColor.fromInt(primaryColor.toARGB32());

    // Pre-fetch images
    Uint8List? logoBytes;
    try {
      final logoUrl = _logoUrl;
      if (logoUrl != null) {
        logoBytes = await _fetchImageBytes(logoUrl);
      }
      if (logoBytes == null) {
        final ByteData data = await rootBundle.load(
          'assets/images/gas_logo.webp',
        );
        logoBytes = data.buffer.asUint8List();
      }
    } catch (e) {
      debugPrint("Error loading logo: $e");
    }

    Uint8List? plateBytes;
    Uint8List? neckBytes;

    final plateUrl = _formatImageUrl(certificate.photoNumberPlate);
    if (plateUrl != null) {
      plateBytes = await _fetchImageBytes(plateUrl);
    }

    final neckUrl = _formatImageUrl(certificate.photoMarkingDetails);
    if (neckUrl != null) {
      neckBytes = await _fetchImageBytes(neckUrl);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            // Header with Logo
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (logoBytes != null)
                  pw.Image(
                    pw.MemoryImage(logoBytes),
                    width: 70,
                    height: 70,
                    fit: pw.BoxFit.contain,
                  ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (_companyName.isNotEmpty)
                        pw.Text(
                          _companyName.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 17,
                            fontWeight: pw.FontWeight.bold,
                            color: pdfPrimary,
                          ),
                        ),
                      if (_tagline.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          _tagline.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                      if (_licenseName.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          "License Name: $_licenseName",
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: pdfPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
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
            if (_shouldShowPhotos) ...[
              pw.SizedBox(height: 15),
              pw.Text(
                "Certificate Photos:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              _buildPdfPhotoSection(plateBytes, neckBytes),
            ],

            pw.SizedBox(height: 15),
            pw.Text("Remarks: ${certificate.remark ?? '---'}"),
            pw.SizedBox(height: 30),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  _userName.isNotEmpty
                      ? "Test done by:\n$_userName"
                      : "Test done by:",
                  textAlign: pw.TextAlign.center,
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
                "Minimum Calculated",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                "Minimum Observed",
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
                    "Perm Exp %",
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
