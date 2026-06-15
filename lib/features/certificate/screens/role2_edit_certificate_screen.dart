import 'dart:io';
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:premium_engneering_app/features/home/provider/home_state.dart';
import '../../home/screens/role1_screen.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme.dart';
import '../../../widgets/custom_widgets.dart';
import '../../home/provider/home_provider.dart';
import '../../home/model/role1_certificate_list_model.dart';
import '../../auth/data/auth_repository.dart';

class Role2EditCertificateScreen extends StatefulWidget {
  final CertificateData certificate;
  const Role2EditCertificateScreen({super.key, required this.certificate});

  @override
  State<Role2EditCertificateScreen> createState() =>
      _Role2EditCertificateScreenState();
}

class _Role2EditCertificateScreenState
    extends State<Role2EditCertificateScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController vehicleNumberController;
  late TextEditingController mobileNumberController;
  late TextEditingController manufacturingMonthController;
  late TextEditingController manufacturingYearController;
  late TextEditingController expiryYearController;
  late TextEditingController cascadeNoController;

  // Role 2 expansion controllers
  late TextEditingController expansionInitialController;
  late TextEditingController expansionTotalController;
  late TextEditingController expansionPermController;
  late TextEditingController expansionPctController;
  late TextEditingController capacityController;
  late TextEditingController retailCustNameController;
  late TextEditingController cceNoController;
  String? selectedResult;

  String? selectedVehicleType;
  int? selectedVehicleTypeId;
  String? selectedVehicleFormat;
  String? selectedDealer;
  dynamic selectedDealerId;
  String? selectedCylinderMakeName;
  String? selectedCylinderMakeId;
  String? testDate;
  String? nextTestDate;
  String? fillingPermDate;
  String? lastTestingDate;
  String? weightErrorMessage;
  bool isCylinderExpired = false;
  bool isEarlyTestingDetected = false;

  // Vehicle check state
  bool isVehicleWarning = false;
  bool isRemarkRequired = false;
  String? vehicleWarningMessage;

  // Testing Details Controllers
  late TextEditingController initialObsController;
  late TextEditingController visualObsController;
  late TextEditingController threadingObsController;
  late TextEditingController internalObsController;
  late TextEditingController tareWeightController;
  late TextEditingController actualWeightController;
  late TextEditingController weightLossKgController;
  late TextEditingController weightLossPctController;
  late TextEditingController cylinderSizeController;

  late TextEditingController shellMinController;
  late TextEditingController shellObsController;
  late TextEditingController bottomMinController;
  late TextEditingController bottomObsController;
  late TextEditingController remarksController;
  late TextEditingController serialNoController;
  late TextEditingController amountController;

  // Inspections Status
  String? initialStatus;
  String? visualStatus;
  String? threadingStatus;
  String? internalStatus;
  String? plateStatus;

  Map<String, String?> pickedImages = {"plate": null, "neck": null};

  @override
  void initState() {
    super.initState();
    final cert = widget.certificate;

    vehicleNumberController = TextEditingController(text: cert.vehicleNumber);
    mobileNumberController = TextEditingController(text: cert.mobile ?? "");
    cascadeNoController = TextEditingController(
      text: cert.cascadeNumber ?? cert.cascadeNo,
    );

    capacityController = TextEditingController(text: cert.waterCapacity);
    expansionInitialController = TextEditingController(
      text: cert.initialExpansion,
    );
    expansionTotalController = TextEditingController(text: cert.totalExpansion);
    expansionPermController = TextEditingController(
      text: cert.permanentExpansion,
    );
    expansionPctController = TextEditingController(
      text: cert.permanentExpansionPercentage,
    );
    cceNoController = TextEditingController(text: cert.cceFillingPermissionNo);
    selectedResult = cert.result ?? "PASS";

    initialObsController = TextEditingController(
      text: cert.valveInspectionRemark,
    );
    visualObsController = TextEditingController(
      text: cert.visualInspectionRemark,
    );
    threadingObsController = TextEditingController(
      text: cert.cylinderThreadingRemark,
    );
    internalObsController = TextEditingController(
      text: cert.internalInspectionRemark,
    );
    tareWeightController = TextEditingController(text: cert.originalTareWeight);
    actualWeightController = TextEditingController(text: cert.actualWeight);
    weightLossKgController = TextEditingController(text: cert.lossOfWeight);
    weightLossPctController = TextEditingController(
      text: cert.lossOfWeightPercentage,
    );
    cylinderSizeController = TextEditingController(text: cert.dieOfCylinder);

    shellMinController = TextEditingController(text: cert.shellMinCalThick);
    shellObsController = TextEditingController(text: cert.shellObsThickMin);
    bottomMinController = TextEditingController(text: cert.bottomMinCalThick);
    bottomObsController = TextEditingController(text: cert.bottomObsThickMin);
    remarksController = TextEditingController(text: cert.remark);
    serialNoController = TextEditingController(text: cert.cylinderSerialNo);
    amountController = TextEditingController(text: cert.retailerAmount ?? cert.paymentAmount ?? "");

    initialStatus = cert.valveInspection == "0" ? "OK" : "Not OK";
    visualStatus = cert.visualInspection == "0" ? "OK" : "Not OK";
    threadingStatus = cert.cylinderThreading == "0" ? "OK" : "Not OK";
    internalStatus = cert.internalInspection == "0" ? "OK" : "Not OK";
    plateStatus = "OK";

    final List<String> monthNames = [
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

    if (cert.manufacturingDate != null &&
        cert.manufacturingDate!.contains("-")) {
      final parts = cert.manufacturingDate!.split("-");
      if (parts[0].length == 4) {
        // YYYY-MM-DD
        int? monthIdx = int.tryParse(parts[1]);
        manufacturingMonthController = TextEditingController(
          text: (monthIdx != null && monthIdx >= 1 && monthIdx <= 12)
              ? monthNames[monthIdx - 1]
              : parts[1],
        );
        manufacturingYearController = TextEditingController(text: parts[0]);
      } else {
        // MM-YYYY or Name-YYYY
        int? monthIdx = int.tryParse(parts[0]);
        manufacturingMonthController = TextEditingController(
          text: (monthIdx != null && monthIdx >= 1 && monthIdx <= 12)
              ? monthNames[monthIdx - 1]
              : parts[0],
        );
        manufacturingYearController = TextEditingController(text: parts[1]);
      }
    } else {
      manufacturingMonthController = TextEditingController();
      manufacturingYearController = TextEditingController();
    }

    // Initialize Expiry Controller
    String initialExpiry = cert.expireDate ?? "";
    if (initialExpiry.contains("-")) {
      final parts = initialExpiry.split("-");
      if (parts[0].length == 4) {
        // YYYY-MM-DD -> MM-YYYY
        initialExpiry = "${parts[1]}-${parts[0]}";
      }
    }
    expiryYearController = TextEditingController(text: initialExpiry);

    final isRetailInitial = (cert.dealerId == 'rc001' ||
        cert.dealerId == 'rc01' ||
        cert.dealerId == 0 ||
        cert.dealerId == '0' ||
        cert.dealerName == "Retail Customer");

    selectedVehicleType = cert.vehicalType;
    selectedVehicleTypeId = int.tryParse(cert.vehicalType ?? "");
    selectedVehicleFormat = cert.vehicleFormat;
    selectedCylinderMakeName = cert.cylinderMake;
    selectedCylinderMakeId = cert.cylinderMake;
    selectedDealer = isRetailInitial ? "Retail Customer" : cert.dealerName;
    selectedDealerId = isRetailInitial ? 'rc001' : cert.dealerId;
    retailCustNameController = TextEditingController(
      text: isRetailInitial ? cert.dealerName : "",
    );

    // Parse Role 2 dates (Convert YYYY-MM-DD to DD-MM-YYYY)
    if (cert.testDate != null && cert.testDate!.contains("-")) {
      final p = cert.testDate!.split("-");
      testDate = p[0].length == 4 ? "${p[2]}-${p[1]}-${p[0]}" : cert.testDate;
    }
    if (cert.nextTestDate != null && cert.nextTestDate!.contains("-")) {
      final p = cert.nextTestDate!.split("-");
      nextTestDate = p[0].length == 4
          ? "${p[2]}-${p[1]}-${p[0]}"
          : cert.nextTestDate;
    }
    if (cert.lastTestDate != null && cert.lastTestDate!.contains("-")) {
      final p = cert.lastTestDate!.split("-");
      lastTestingDate = p[0].length == 4
          ? "${p[2]}-${p[1]}-${p[0]}"
          : cert.lastTestDate;
    }
    if (cert.fillingPermissionDate != null &&
        cert.fillingPermissionDate!.contains("-")) {
      final p = cert.fillingPermissionDate!.split("-");
      fillingPermDate = p[0].length == 4
          ? "${p[2]}-${p[1]}-${p[0]}"
          : cert.fillingPermissionDate;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<HomeProvider>();

      // Sync isRetailCustomer state
      final isRetail =
          (selectedDealerId == 'rc001' ||
          selectedDealerId == 'rc01' ||
          selectedDealerId == 0 ||
          selectedDealerId == '0' ||
          selectedDealer == "Retail Customer");
      provider.setIsRetailCustomer(isRetail);

      final dId = isRetail ? 'rc001' : (selectedDealerId?.toString() ?? '');
      await provider.getVehicleType(dId);
      provider.getVehicleFormat();
      provider.getDealerType();
      provider.getCylinderMake();
      await provider.loadHomeData();

      // Resolve Vehicle Type ID
      if (selectedVehicleType != null &&
          provider.state.vehicleTypeData?.data != null) {
        try {
          final match = provider.state.vehicleTypeData!.data!.firstWhere(
            (e) =>
                e.vehicleName == selectedVehicleType ||
                e.id.toString() == selectedVehicleType,
          );
          if (mounted) {
            setState(() {
              selectedVehicleTypeId = match.id;
            });
          }
        } catch (_) {}
      }

      // Set selected product for price fetching
      if (provider.state.homeData?.data != null) {
        try {
          final product = provider.state.homeData!.data!.firstWhere(
            (p) =>
                p.fullname == cert.productType &&
                p.standard == cert.specification,
          );
          provider.setSelectedProduct(product);

          // Fetch initial amount
          if (selectedVehicleTypeId != null) {
            provider.getProductAmountByDealer({
              'dealer_id': dId,
              'vehicle_id': selectedVehicleTypeId.toString(),
              'product_id': product.id.toString(),
            });
          }
        } catch (_) {
          if (provider.state.homeData!.data!.isNotEmpty) {
            provider.setSelectedProduct(provider.state.homeData!.data!.first);
          }
        }
      }
      _syncExpiryDate();

    });
  }

  @override
  void dispose() {
    vehicleNumberController.dispose();
    mobileNumberController.dispose();
    manufacturingMonthController.dispose();
    manufacturingYearController.dispose();
    cceNoController.dispose();
    expiryYearController.dispose();
    initialObsController.dispose();
    visualObsController.dispose();
    threadingObsController.dispose();
    internalObsController.dispose();
    tareWeightController.dispose();
    actualWeightController.dispose();
    weightLossKgController.dispose();
    weightLossPctController.dispose();
    cylinderSizeController.dispose();
    shellMinController.dispose();
    shellObsController.dispose();
    bottomMinController.dispose();
    bottomObsController.dispose();
    remarksController.dispose();
    serialNoController.dispose();
    capacityController.dispose();
    expansionInitialController.dispose();
    expansionTotalController.dispose();
    expansionPermController.dispose();
    expansionPctController.dispose();
    cascadeNoController.dispose();
    retailCustNameController.dispose();
    context.read<HomeProvider>().clearProductAmount();
    context.read<HomeProvider>().clearDealerAmount();
    super.dispose();
  }

  void _syncExpiryDate() {
    final year = int.tryParse(manufacturingYearController.text);
    if (year != null && manufacturingMonthController.text.isNotEmpty) {
      final List<String> monthNames = [
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
      int monthIndex = monthNames.indexOf(manufacturingMonthController.text);
      if (monthIndex != -1) {
        final provider = context.read<HomeProvider>();
        final lifeYears =
            provider.state.homeData?.data?.firstOrNull?.lifeOfCylinder ?? 20;
        int expiryYearValue = year + lifeYears;
        String month = (monthIndex + 1).toString().padLeft(2, '0');

        DateTime now = DateTime.now();
        bool expired = false;
        if (expiryYearValue < now.year) {
          expired = true;
        } else if (expiryYearValue == now.year) {
          if ((monthIndex + 1) < now.month) {
            expired = true;
          }
        }

        setState(() {
          expiryYearController.text = "$month-$expiryYearValue";
          isCylinderExpired = expired;
        });
        if (expired) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showExpiredWarningDialog();
          });
        }
      }
    }
  }

  void _showExpiredWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text("Cylinder Expired", style: TextStyle(color: Colors.red)),
          ],
        ),
        content: const Text(
          "your cylinder expire you can not perform test",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "OK",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedExpiryDate() {
    if (expiryYearController.text.isEmpty) return "Auto Calculated";
    try {
      final parts = expiryYearController.text.split("-");
      if (parts.length >= 2) {
        final monthInt = int.tryParse(parts[0]);
        final year = parts[1];
        if (monthInt != null && monthInt >= 1 && monthInt <= 12) {
          final List<String> monthNames = [
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
          return "${monthNames[monthInt - 1]} $year";
        }
      }
      return expiryYearController.text;
    } catch (e) {
      return expiryYearController.text;
    }
  }

  void _syncFillingPermDate() {
    if (manufacturingMonthController.text.isNotEmpty &&
        manufacturingYearController.text.isNotEmpty) {
      final List<String> monthNames = [
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
      int monthIndex = monthNames.indexOf(manufacturingMonthController.text);
      if (monthIndex != -1) {
        String month = (monthIndex + 1).toString().padLeft(2, '0');
        String year = manufacturingYearController.text;
        setState(() {
          fillingPermDate = "01-$month-$year";
        });
      }
    }
  }

  Future<void> _checkVehicleNumber(String vehicleNo) async {
    if (vehicleNo.isEmpty) return;
    try {
      final authRepo = context.read<AuthRepository>();
      final userId = await authRepo.getUserId();
      final adminId = await authRepo.getAdminId();
      final provider = context.read<HomeProvider>();
      final intervalCount =
          provider.state.homeData?.data?.firstOrNull?.intervalTesting ?? 3;

      final now = DateTime.now();
      final fallbackDate =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      final testDateStr = (testDate != null && testDate!.isNotEmpty)
          ? testDate!
          : fallbackDate;

      await provider.checkVehicleNumber({
        'vehicleno': vehicleNo,
        'userid': userId ?? '',
        'admin_id': adminId ?? '',
        'intervel_count': intervalCount.toString(),
        'collection_date': testDateStr,
        'vehicle_type_id': selectedVehicleTypeId?.toString() ?? '',
        'product_id': provider.state.selectedProduct?.id?.toString() ?? '',
      });

      final response = provider.state.vehicleCheckData;
      if (response != null) {
        final status = response['status'];
        final message = response['message']?.toString() ?? '';
        final isWarning =
            status == true ||
            status == 'true' ||
            status == 1 ||
            status.toString().toLowerCase() == 'success';
        if (isWarning && message.isNotEmpty) {
          if (mounted) {
            setState(() {
              isVehicleWarning = true;
              vehicleWarningMessage = message;
              isRemarkRequired = true;
            });
            _showVehicleWarningDialog(message);
          }
        } else {
          if (mounted) {
            setState(() {
              isVehicleWarning = false;
              vehicleWarningMessage = null;
              isRemarkRequired = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Role2 edit vehicle check error: $e');
    }
  }

  void _showVehicleWarningDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text("Vehicle Alert"),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "OK",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkIntervalWarning() {
    if (testDate == null ||
        manufacturingMonthController.text.isEmpty ||
        manufacturingYearController.text.isEmpty) {
      return;
    }

    try {
      // Parse testDate (DD-MM-YYYY)
      final testParts = testDate!.split("-");
      if (testParts.length != 3) return;
      final testDateTime = DateTime(
        int.parse(testParts[2]),
        int.parse(testParts[1]),
        int.parse(testParts[0]),
      );

      // Parse Mfg Date
      final List<String> monthNames = [
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
      int monthIndex = monthNames.indexOf(manufacturingMonthController.text);
      if (monthIndex == -1) return;
      int mfgYear = int.parse(manufacturingYearController.text);
      final mfgDateTime = DateTime(mfgYear, monthIndex + 1, 1);

      // Get interval from provider
      final provider = context.read<HomeProvider>();
      final intervalTesting =
          provider.state.homeData?.data?.firstOrNull?.intervalTesting ?? 3;

      // Logic: If test date is BEFORE (Mfg Date + Interval)
      final thresholdDate = DateTime(
        mfgYear + intervalTesting,
        monthIndex + 1,
        1,
      );

      if (testDateTime.isBefore(thresholdDate)) {
        setState(() {
          isEarlyTestingDetected = true;
        });
        _showEarlyTestingDialog();
      } else {
        setState(() {
          isEarlyTestingDetected = false;
        });
      }
    } catch (e) {
      debugPrint("Error checking interval: $e");
    }
  }

  void _showEarlyTestingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text("Testing Alert"),
          ],
        ),
        content: const Text(
          "You’ve come in for testing earlier than the scheduled interval. If you proceed, you must provide a reason in the Remarks field below.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _calculateWeightLoss() {
    double original = double.tryParse(tareWeightController.text) ?? 0.0;
    double actual = double.tryParse(actualWeightController.text) ?? 0.0;

    if (original > 0 && actual > 0) {
      double loss = original - actual;
      double lossPct = (loss / original) * 100;

      bool wasErrorMessageNull = weightErrorMessage == null;

      setState(() {
        weightLossKgController.text = loss.toStringAsFixed(3);
        weightLossPctController.text = lossPct.toStringAsFixed(2);

        if (lossPct > 5.0) {
          weightErrorMessage =
              "Loss of weight exceeds 5%. Cylinder may be rejected.";
          if (wasErrorMessageNull) {
            _showWeightWarningDialog(weightErrorMessage!);
          }
        } else {
          weightErrorMessage = null;
        }
      });
    }
  }

  void _showWeightWarningDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text("Weight Alert"),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "OK",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _calculateExpansion() {
    final c1Str = expansionInitialController.text.trim();
    final c2Str = expansionTotalController.text.trim();
    final c3Str = expansionPermController.text.trim();

    if (c1Str.isNotEmpty && c2Str.isNotEmpty && c3Str.isNotEmpty) {
      double c1 = double.tryParse(c1Str) ?? 0.0;
      double c2 = double.tryParse(c2Str) ?? 0.0;
      double c3 = double.tryParse(c3Str) ?? 0.0;

      if ((c2 - c1) != 0) {
        double percentage = ((c3 - c1) / (c2 - c1)) * 100;
        setState(() {
          expansionPctController.text = percentage.toStringAsFixed(2);
          if (percentage > 10.0) {
            selectedResult = "FAIL";
          } else {
            selectedResult = "PASS";
          }
        });
      }
    } else {
      setState(() {
        expansionPctController.text = "";
      });
    }
  }

  Future<void> _pickAndCompressImage(String tag) async {
    final ImagePicker picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = await picker.pickImage(source: source);
    if (image == null) {
      debugPrint("DEBUG: Image picking cancelled or failed for $tag");
      return;
    }

    debugPrint("DEBUG: Image Picker SUCCESS for $tag. Path: ${image.path}");
    setState(() {
      pickedImages[tag] = image.path;
    });
    debugPrint(
      "DEBUG: pickedImages state updated. Current value for $tag: ${pickedImages[tag]}",
    );
  }

  @override
  Widget build(BuildContext context) {
    String? formatDisplayDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty || !dateStr.contains("-")) {
        return dateStr;
      }
      final parts = dateStr.split("-");
      if (parts.length == 3 && parts[0].length == 4) {
        return "${parts[2]}-${parts[1]}-${parts[0]}";
      }
      return dateStr;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Update Certificate (Role 2)",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.always,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(height: 20),

              _buildSectionHeader("License Details"),
              _buildActionCard(
                child: Column(
                  children: [
                    const _RowLabels(l1: "License Name", l2: "Approval No"),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ValueBox(
                            text: widget.certificate.licenseName ?? "N/A",
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ValueBox(
                            text: widget.certificate.approvalNo ?? "N/A",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              _buildSectionHeader("Vehicle Details"),
              Consumer<HomeProvider>(
                builder: (context, provider, _) {
                  final vehicleTypes =
                      provider.state.vehicleTypeData?.data ?? [];
                  final types = vehicleTypes
                      .map((e) => e.vehicleName ?? "")
                      .toList();

                  // Resolve the display name for the current selected type (handle IDs or names)
                  String resolvedTypeName = selectedVehicleType ?? "";
                  try {
                    final match = vehicleTypes.firstWhere(
                      (e) =>
                          e.id.toString() == resolvedTypeName ||
                          e.vehicleName == resolvedTypeName,
                    );
                    resolvedTypeName = match.vehicleName ?? resolvedTypeName;
                  } catch (_) {}
                  final bool isCascade = resolvedTypeName
                      .toLowerCase()
                      .contains('cascade');
                  bool isCNG = false;
                  final productName = provider.state.selectedProduct?.fullname?.toLowerCase() ?? '';
                  if (productName.contains('cng') || (productName.contains('compress') && productName.contains('natural') && productName.contains('gas'))) {
                    isCNG = true;
                  }
                  return _buildActionCard(
                    child: Column(
                      children: [
                        Consumer<HomeProvider>(
                          builder: (context, provider, _) {
                            final dealerList =
                                provider.state.dealerTypeData?.data ?? [];
                            final dealers = [
                              "Retail Customer",
                              ...dealerList.map((e) => e.fullname ?? ""),
                            ];
                            final isRetail = provider.state.isRetailCustomer;

                            String displayValue = selectedDealer ?? "Dealer";
                            if (selectedDealerId != null) {
                              try {
                                final match = dealerList.firstWhere(
                                  (e) =>
                                      e.id?.toString() ==
                                      selectedDealerId?.toString(),
                                );
                                displayValue = match.fullname ?? displayValue;
                              } catch (_) {}
                            }

                            return Column(
                              children: [
                                _RowLabels(
                                  l1: "Choose Dealer",
                                  l2: isRetail ? "Retail Customer Name" : "Mobile Number",
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _DropDownField(
                                        enabled: !isRetail,
                                        hint: displayValue,
                                        items: dealers,
                                        validator: (v) =>
                                            (selectedDealer == null)
                                            ? ""
                                            : null,
                                        onChanged: (val) {
                                          if (val == null ||
                                              val == "Retail Customer") {
                                            provider.setIsRetailCustomer(true);
                                            setState(() {
                                              selectedDealer = val;
                                              selectedDealerId = 'rc001';
                                              mobileNumberController.clear();
                                            });
                                            provider.clearDealerAmount();
                                            provider.clearProductAmount();
                                            provider.getVehicleType('rc001');
                                            return;
                                          }

                                          try {
                                            final selected = dealerList
                                                .firstWhere(
                                                  (e) => e.fullname == val,
                                                );
                                            final retail =
                                                val?.toLowerCase().contains(
                                                  'retail',
                                                ) ??
                                                false;
                                            provider.setIsRetailCustomer(
                                              retail,
                                            );

                                            setState(() {
                                              selectedDealer = val;
                                              selectedDealerId = selected.id;
                                              if (!retail) {
                                                mobileNumberController.text =
                                                    selected.mobileNo ?? '';
                                              }
                                            });

                                            if (retail) {
                                              provider.clearDealerAmount();
                                              provider.clearProductAmount();
                                              provider.getVehicleType('rc001');
                                            } else if (selected.id != null) {
                                              provider.getVehicleType(
                                                selected.id.toString(),
                                              );
                                              provider
                                                  .getProductAmountByDealer({
                                                    'dealer_id': selected.id
                                                        .toString(),
                                                    'vehicle_id':
                                                        selectedVehicleTypeId
                                                            ?.toString() ??
                                                        '',
                                                    'product_id':
                                                        provider
                                                            .state
                                                            .selectedProduct
                                                            ?.id
                                                            ?.toString() ??
                                                        '',
                                                  });
                                            }
                                          } catch (_) {}
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    if (!isRetail)
                                      Expanded(
                                        child: _ManualField(
                                          hint: "Mobile",
                                          controller: mobileNumberController,
                                          keyboardType: TextInputType.phone,
                                          validator: (v) {
                                            if (v == null || v.isEmpty)
                                              return "Required";
                                            if (v.length != 10)
                                              return "10 digits required";
                                            return null;
                                          },
                                        ),
                                      )
                                    else
                                      Expanded(
                                        child: _ManualField(
                                          hint: "Enter Customer Name",
                                          controller: retailCustNameController,
                                          validator: (val) {
                                            if (isRetail &&
                                                (val == null || val.isEmpty)) {
                                              return "Required";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                                if (isRetail) ...[
                                  const SizedBox(height: 15),
                                  const _RowLabels(
                                    l1: "Enter Amount",
                                    l2: "Enter Mobile No.",
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _ManualField(
                                          hint: "Enter Amount",
                                          controller: amountController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          validator: (val) {
                                            if (isRetail &&
                                                (val == null || val.isEmpty)) {
                                              return "Required";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _ManualField(
                                          hint: "Enter Mobile Number",
                                          controller: mobileNumberController,
                                          keyboardType: TextInputType.phone,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(10),
                                          ],
                                          validator: (val) {
                                            if (val == null || val.isEmpty) {
                                              return "Required";
                                            }
                                            if (val.length != 10) {
                                              return "Must be 10 digits";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        const _RowLabels(l1: "Vehicle Type", l2: "Test Date"),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _DropDownField(
                                hint: resolvedTypeName.isEmpty
                                    ? "Select Type"
                                    : resolvedTypeName,
                                items: types,
                                validator: (v) =>
                                    (selectedVehicleType == null) ? "" : null,
                                onChanged: (val) {
                                  try {
                                    final selected = vehicleTypes.firstWhere(
                                      (e) => e.vehicleName == val,
                                    );
                                    setState(() {
                                      selectedVehicleType = val;
                                      selectedVehicleTypeId = selected.id;
                                    });

                                    final dId = provider.state.isRetailCustomer
                                        ? '0'
                                        : selectedDealerId?.toString();

                                    debugPrint(
                                      "Role2Edit: Vehicle changed. dId: $dId, vId: ${selected.id}, pId: ${provider.state.selectedProduct?.id}",
                                    );

                                    if (selected.id != null && dId != null) {
                                      provider.getProductAmountByDealer({
                                        'dealer_id': dId,
                                        'vehicle_id': selected.id.toString(),
                                        'product_id':
                                            provider.state.selectedProduct?.id
                                                ?.toString() ??
                                            '',
                                      });
                                    }
                                  } catch (_) {}
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _DatePickerField(
                                displayDate: formatDisplayDate(testDate),
                                validator: (v) =>
                                    (testDate == null) ? "" : null,
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      testDate =
                                          "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
                                      final provider = context
                                          .read<HomeProvider>();
                                      final years =
                                          provider
                                              .state
                                              .homeData
                                              ?.data
                                              ?.firstOrNull
                                              ?.intervalTesting ??
                                          3;
                                      try {
                                        final nextDate = DateTime(
                                          date.year + years,
                                          date.month,
                                          date.day,
                                        ).subtract(const Duration(days: 1));
                                        nextTestDate =
                                            "${nextDate.day.toString().padLeft(2, '0')}-${nextDate.month.toString().padLeft(2, '0')}-${nextDate.year}";
                                      } catch (e) {
                                        debugPrint(
                                          "Error calculating next test date: $e",
                                        );
                                      }
                                      _checkIntervalWarning();
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Consumer<HomeProvider>(
                          builder: (context, provider, _) {
                            if (provider.state.productAmountStatus ==
                                    HomeStatus.success &&
                                provider.state.productAmount != null &&
                                selectedVehicleTypeId != null) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Product Amount: ₹ ${provider.state.productAmount}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    if (provider.state.totalDuesPending !=
                                        null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        "Total Dues Pending: ₹ ${provider.state.totalDuesPending}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 15),
                        if (isCascade) ...[
                          const _RowLabels(l1: "Enter Cascade Number", l2: ""),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _ManualField(
                                  hint: "Enter Cascade Number",
                                  controller: cascadeNoController,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return "";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ] else if (isCNG) ...[
                          const _RowLabels(
                            l1: "Choose Vehicle Format",
                            l2: "Add Vehicle Number",
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Consumer<HomeProvider>(
                                  builder: (context, provider, _) {
                                    final formats =
                                        provider.state.vehicleFormatData?.data
                                            ?.map((e) => e.vFormat ?? "")
                                            .toList() ??
                                        [];
                                    return _DropDownField(
                                      hint: selectedVehicleFormat ?? "Format",
                                      items: formats,
                                      validator: (v) {
                                        if (isCascade) return null;
                                        return (selectedVehicleFormat == null)
                                            ? ""
                                            : null;
                                      },
                                      onChanged: (val) => setState(
                                        () => selectedVehicleFormat = val,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ManualField(
                                  hint: "Number",
                                  controller: vehicleNumberController,
                                  validator: (v) {
                                    if (isCascade) return null;
                                    return (v == null || v.isEmpty) ? "" : null;
                                  },
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  keyboardType:
                                      (selectedVehicleFormat != null &&
                                          !selectedVehicleFormat!
                                              .toUpperCase()
                                              .contains('X'))
                                      ? TextInputType.number
                                      : TextInputType.visiblePassword,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(
                                      (selectedVehicleFormat?.isNotEmpty ==
                                              true)
                                          ? selectedVehicleFormat!.length
                                          : 13,
                                    ),
                                    VehicleNumberSmartFormatter(
                                      selectedVehicleFormat,
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val.length >= 6) {
                                      _checkVehicleNumber(val);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 15),
                        const _RowLabels(l1: "Next Test Due Date", l2: ""),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _ValueBox(
                                text:
                                    formatDisplayDate(nextTestDate) ??
                                    "Auto Calculated",
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),

              _buildSectionHeader("Product Details"),
              _buildActionCard(
                child: Column(
                  children: [
                    const _RowLabels(
                      l1: "Product Type",
                      l2: "Cylinder Specification",
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ValueBox(
                            text: widget.certificate.productType ?? "N/A",
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ValueBox(
                            text: widget.certificate.specification ?? "N/A",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const _RowLabels(
                      l1: "Sl No/Balance Cylinder No:",
                      l2: "Last Testing Date",
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ManualField(
                            hint: "Cylinder Serial No",
                            controller: serialNoController,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? "" : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DatePickerField(
                            displayDate: formatDisplayDate(lastTestingDate),
                            validator: (v) =>
                                (lastTestingDate == null) ? "" : null,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() {
                                  lastTestingDate =
                                      "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const _RowLabels(
                      l1: "Cylinder Make",
                      l2: "Manufacturing Date",
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          child: Consumer<HomeProvider>(
                            builder: (context, provider, _) {
                              final data =
                                  provider.state.cylinderMakeData?.data ?? [];
                              final items = data
                                  .map((e) => e.fullname ?? "")
                                  .toList();
                              String displayValue =
                                  selectedCylinderMakeName ?? "Select";
                              try {
                                final match = data.firstWhere(
                                  (e) =>
                                      e.id.toString() == displayValue ||
                                      e.fullname == displayValue,
                                );
                                displayValue = match.fullname ?? displayValue;
                              } catch (_) {}

                              return _DropDownField(
                                hint: displayValue,
                                items: items,
                                validator: (v) =>
                                    (selectedCylinderMakeId == null)
                                    ? ""
                                    : null,
                                onChanged: (v) {
                                  final selected = data.firstWhere(
                                    (e) => e.fullname == v,
                                  );
                                  setState(() {
                                    selectedCylinderMakeName = v;
                                    selectedCylinderMakeId = selected.id
                                        ?.toString();
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _DatePickerField(
                                  displayDate:
                                      manufacturingMonthController.text.isEmpty
                                      ? "Month"
                                      : manufacturingMonthController.text,
                                  validator: (v) =>
                                      (manufacturingMonthController
                                          .text
                                          .isEmpty)
                                      ? ""
                                      : null,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        final List<String> monthNames = [
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
                                        return AlertDialog(
                                          title: const Text("Select Month"),
                                          content: SizedBox(
                                            width: 300,
                                            height: 300,
                                            child: ListView.builder(
                                              itemCount: 12,
                                              itemBuilder: (context, index) {
                                                final monthName =
                                                    monthNames[index];
                                                final monthNumber = index + 1;
                                                final now = DateTime.now();

                                                int?
                                                selectedYear = int.tryParse(
                                                  manufacturingYearController
                                                      .text,
                                                );
                                                bool isCurrentYear =
                                                    selectedYear == null ||
                                                    selectedYear == now.year;
                                                bool isFutureMonth =
                                                    isCurrentYear &&
                                                    monthNumber > now.month;

                                                return ListTile(
                                                  title: Text(
                                                    monthName,
                                                    style: TextStyle(
                                                      color: isFutureMonth
                                                          ? Colors.grey
                                                          : Colors.black87,
                                                    ),
                                                  ),
                                                  enabled: !isFutureMonth,
                                                  onTap: isFutureMonth
                                                      ? null
                                                      : () {
                                                          setState(() {
                                                            manufacturingMonthController
                                                                    .text =
                                                                monthName;
                                                            _syncFillingPermDate();
                                                            _syncExpiryDate();
                                                          });
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          _checkIntervalWarning();
                                                        },
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: _DatePickerField(
                                  displayDate:
                                      manufacturingYearController.text.isEmpty
                                      ? "Year"
                                      : manufacturingYearController.text,
                                  validator: (v) =>
                                      (manufacturingYearController.text.isEmpty)
                                      ? " "
                                      : null,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text("Select Year"),
                                          content: SizedBox(
                                            width: 300,
                                            height: 300,
                                            child: YearPicker(
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime.now(),
                                              selectedDate: DateTime.now(),
                                              onChanged: (DateTime dateTime) {
                                                setState(() {
                                                  manufacturingYearController
                                                      .text = dateTime.year
                                                      .toString();

                                                  // Clear month if it becomes invalid for current year
                                                  final now = DateTime.now();
                                                  if (dateTime.year ==
                                                      now.year) {
                                                    final monthText =
                                                        manufacturingMonthController
                                                            .text;
                                                    if (monthText.isNotEmpty) {
                                                      final List<String>
                                                      monthNames = [
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
                                                      int monthIndex =
                                                          monthNames.indexOf(
                                                            monthText,
                                                          );
                                                      if (monthIndex + 1 >
                                                          now.month) {
                                                        manufacturingMonthController
                                                                .text =
                                                            "";
                                                      }
                                                    }
                                                  }

                                                  _syncFillingPermDate();
                                                  _syncExpiryDate();
                                                  _checkIntervalWarning();
                                                });
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const _RowLabels(
                      l1: "CCE No(gas Filling Perm: (No",
                      l2: "Filling Permission Date",
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ManualField(
                            hint: "CCE Number",
                            controller: cceNoController,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? "" : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DatePickerField(
                            displayDate: formatDisplayDate(fillingPermDate),
                            validator: (v) =>
                                (fillingPermDate == null) ? "" : null,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() {
                                  fillingPermDate =
                                      "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Text(
                          "Expiry Date",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isCylinderExpired) ...[
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              "your cylinder expire you can not perform test",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ValueBox(text: _getFormattedExpiryDate()),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),

              if (!isCylinderExpired) ...[
                _buildSectionHeader("Testing Details"),
                _buildActionCard(
                  child: Column(
                    children: [
                      const _RowLabels(
                        l1: "Valve Inspection",
                        l2: "Visual Inspection",
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _DropDownField(
                              hint: initialStatus ?? "OK",
                              items: const ["OK", "Not OK"],
                              validator: (v) =>
                                  (initialStatus == null) ? "" : null,
                              onChanged: (v) =>
                                  setState(() => initialStatus = v),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _DropDownField(
                              hint: visualStatus ?? "OK",
                              items: const ["OK", "Not OK"],
                              validator: (v) =>
                                  (visualStatus == null) ? "" : null,
                              onChanged: (v) =>
                                  setState(() => visualStatus = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const _RowLabels(
                        l1: "Cylinder Threading",
                        l2: "Internal Inspection",
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _DropDownField(
                              hint: threadingStatus ?? "OK",
                              items: const ["OK", "Not OK"],
                              validator: (v) =>
                                  (threadingStatus == null) ? "" : null,
                              onChanged: (v) =>
                                  setState(() => threadingStatus = v),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _DropDownField(
                              hint: internalStatus ?? "OK",
                              items: const ["OK", "Not OK"],
                              validator: (v) =>
                                  (internalStatus == null) ? "" : null,
                              onChanged: (v) =>
                                  setState(() => internalStatus = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const _RowLabels(
                        l1: "Original T.W (Stamped Weight)",
                        l2: "Actual Weight (Measured Weight)",
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _ManualField(
                              hint: "Original Tare Weigh",
                              keyboardType: TextInputType.number,
                              controller: tareWeightController,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? "" : null,
                              onChanged: (_) => _calculateWeightLoss(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ManualField(
                              hint: "Actual Weight",
                              controller: actualWeightController,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? "" : null,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _calculateWeightLoss(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const _RowLabels(
                        l1: "Loss Of Weight(Kg...)",
                        l2: "Loss Of Weight(%)",
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _ValueBox(
                              text: weightLossKgController.text.isEmpty
                                  ? "0.00"
                                  : weightLossKgController.text,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ValueBox(
                              text: weightLossPctController.text.isEmpty
                                  ? "0.00%"
                                  : "${weightLossPctController.text}%",
                            ),
                          ),
                        ],
                      ),
                      if (weightErrorMessage != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            weightErrorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 15),
                      const _RowLabels(
                        l1: "Plate Condition",
                        l2: "Dia of The Cylinder(mm)",
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _DropDownField(
                              hint: plateStatus ?? "OK",
                              items: const ["OK", "Not OK"],
                              validator: (v) =>
                                  (plateStatus == null) ? "" : null,
                              onChanged: (v) => setState(() => plateStatus = v),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ManualField(
                              hint: "Size Of The Cylinder",
                              controller: cylinderSizeController,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? "" : null,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                _buildSectionHeader("Cylinder Wall Thickness"),
                _buildActionCard(
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Shell (mm)",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _ManualField(
                              hint: "Minimum Calculate",
                              keyboardType: TextInputType.number,
                              controller: shellMinController,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? "" : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ManualField(
                              hint: "Observed Thickness",
                              keyboardType: TextInputType.number,
                              controller: shellObsController,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? "" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Thickness of the Center of the Bottom",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _ManualField(
                              hint: "Minimum Calculate",
                              controller: bottomMinController,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? "" : null,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ManualField(
                              hint: "Observed Thickness",
                              controller: bottomObsController,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? "" : null,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                _buildSectionHeader("Hydrostatic Test Details"),
                _buildActionCard(
                  child: Column(
                    children: [
                      const _RowLabels(
                        l1: "Water Capacity (L)",
                        l2: "Working Pressure",
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _ManualField(
                              hint: "Capacity",
                              controller: capacityController,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? "" : null,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ValueBox(
                              text: widget.certificate.workingPressure ?? "204",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const _RowLabels(
                        l1: "Test Pressure",
                        l2: "Initial Expansion",
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _ValueBox(
                              text: widget.certificate.testPressure ?? "340",
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ManualField(
                              hint: "Initial",
                              controller: expansionInitialController,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? "" : null,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _calculateExpansion(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const _RowLabels(
                        l1: "Total Expansion",
                        l2: "Permanent Exp.",
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _ManualField(
                              hint: "Total",
                              controller: expansionTotalController,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? "" : null,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _calculateExpansion(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ManualField(
                              hint: "Permanent",
                              controller: expansionPermController,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? "" : null,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _calculateExpansion(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const _RowLabels(l1: "Permanent Exp (%)", l2: "Result"),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _ValueBox(
                              text: expansionPctController.text.isEmpty
                                  ? "0.00%"
                                  : "${expansionPctController.text}%",
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _DropDownField(
                              hint: selectedResult ?? "PASS",
                              items: const ["PASS", "FAIL"],
                              validator: (v) =>
                                  (selectedResult == null) ? "" : null,
                              onChanged: (v) =>
                                  setState(() => selectedResult = v),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              _buildSectionHeader("Photo Uploads"),
              _buildActionCard(
                child: Column(
                  children: [
                    DashedUploadArea(
                      title: "Update Photo of Number Plate",
                      onPick: () => _pickAndCompressImage("plate"),
                      imagePath: pickedImages["plate"],
                      networkImageUrl:
                          widget.certificate.photoNumberPlate != null &&
                              widget.certificate.photoNumberPlate!.isNotEmpty
                          ? "https://pe.microcmd.com/API/uploads/${widget.certificate.photoNumberPlate}"
                          : null,
                    ),
                    const SizedBox(height: 20),
                    DashedUploadArea(
                      title: "Update Photo of Cylinder Marking",
                      onPick: () => _pickAndCompressImage("neck"),
                      imagePath: pickedImages["neck"],
                      networkImageUrl:
                          widget.certificate.photoMarkingDetails != null &&
                              widget.certificate.photoMarkingDetails!.isNotEmpty
                          ? "https://pe.microcmd.com/API/uploads/${widget.certificate.photoMarkingDetails}"
                          : null,
                    ),
                  ],
                ),
              ),

              _buildSectionHeader("Remarks"),
              _buildActionCard(
                child: _ManualField(
                  hint: "Remarks",
                  controller: remarksController,
                  validator: (v) {
                    if (isEarlyTestingDetected &&
                        (v == null || v.trim().isEmpty)) {
                      return "As you are performing an early test, please specify the reason in the Remarks field.";
                    }
                    return null;
                  },
                  maxLines: 3,
                ),
              ),

              const SizedBox(height: 40),

              Consumer<HomeProvider>(
                builder: (context, provider, _) {
                  return SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "Update Certificate",
                            isLoading:
                                provider.state.certificateStatus ==
                                HomeStatus.loading,
                            onPressed: () async {
                              // if (!_formKey.currentState!.validate()) return;
                              final authRepo = context.read<AuthRepository>();
                              final userId = await authRepo.getUserId();

                              final Map<String, dynamic> data = {
                                'dealer_name': provider.state.isRetailCustomer
                                    ? 'rc01'
                                    : (selectedDealerId?.toString() ?? ''),
                                'dealer': provider.state.isRetailCustomer
                                    ? 'rc01'
                                    : (selectedDealerId?.toString() ?? ''),
                                'photo_number_plate': pickedImages['plate'],
                                'photo_marking_details': pickedImages['neck'],
                                'adminid':
                                    widget.certificate.adminId?.toString() ??
                                    '',
                                'license_name': 'PREMIUM HYDRO ENGINEERING',
                                'approval_no': 'AG/HQ/GJ/GCT/1G49051',
                                'vehical_type':
                                    '${selectedVehicleTypeId ?? selectedVehicleType ?? ''}',
                                'display_number':
                                    '${widget.certificate.displayNumber ?? vehicleNumberController.text}',
                                'vehicle_number':
                                    '${vehicleNumberController.text}',
                                'vehicle_format':
                                    '${selectedVehicleFormat ?? ''}',
                                'cascade_no': '${cascadeNoController.text}',
                                'test_date': '${testDate ?? ''}',
                                'collection_date': '${testDate ?? ''}',
                                'next_test_date': '${nextTestDate ?? ''}',
                                'product_type': 'Compress Natural Gas',
                                'specification': 'IS 15490',
                                'cylinder_serial_no':
                                    '${serialNoController.text}',
                                'last_test_date': lastTestingDate,
                                'cylinder_make':
                                    '${selectedCylinderMakeId ?? ''}',
                                'manufacturing_date':
                                    '${() {
                                      final List<String> monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
                                      String monthStr = manufacturingMonthController.text.trim();
                                      int mIdx = monthNames.indexOf(monthStr);
                                      String mm = (mIdx != -1) ? (mIdx + 1).toString().padLeft(2, '0') : '01';
                                      return '$mm-${manufacturingYearController.text}';
                                    }()}',
                                'cce_filling_permission_no':
                                    '${cceNoController.text}',
                                'filling_permission_date':
                                    '${fillingPermDate ?? ''}',
                                'expire_date': expiryYearController.text,
                                'valve_inspection':
                                    '${initialStatus == "OK" ? "0" : "1"}',
                                'valve_inspection_remark':
                                    initialObsController.text,
                                'visual_inspection':
                                    '${visualStatus == "OK" ? "0" : "1"}',
                                'visual_inspection_remark':
                                    visualObsController.text,
                                'cylinder_threading':
                                    '${threadingStatus == "OK" ? "0" : "1"}',
                                'cylinder_threading_remark':
                                    threadingObsController.text,
                                'internal_inspection':
                                    '${internalStatus == "OK" ? "0" : "1"}',
                                'internal_inspection_remark':
                                    internalObsController.text,
                                'original_tare_weight':
                                    tareWeightController.text,
                                'actual_weight': actualWeightController.text,
                                'loss_of_weight': weightLossKgController.text,
                                'loss_of_weight_percentage':
                                    weightLossPctController.text,
                                'painting': '0',
                                'die_of_cylinder': cylinderSizeController.text,
                                'shell_min_cal_thick': shellMinController.text,
                                'shell_obs_thick_min': shellObsController.text,
                                'bottom_min_cal_thick':
                                    bottomMinController.text,
                                'bottom_obs_thick_min':
                                    bottomObsController.text,
                                'water_capacity': capacityController.text,
                                'working_pressure':
                                    (widget.certificate.workingPressure ?? '')
                                        .toString(),
                                'test_pressure':
                                    (widget.certificate.testPressure ?? '340')
                                        .toString(),
                                'initial_expansion':
                                    expansionInitialController.text,
                                'total_expansion':
                                    expansionTotalController.text,
                                'permanent_expansion':
                                    expansionPermController.text,
                                'permanent_expansion_percentage':
                                    expansionPctController.text,
                                'result': selectedResult ?? 'PASS',
                                'remark': remarksController.text,
                                'userid': userId ?? '',
                                if (provider.state.isRetailCustomer)
                                  'retail_cust_name': retailCustNameController.text,
                                'mobile_no': mobileNumberController.text,
                                if (provider.state.isRetailCustomer)
                                  'retail_amount': amountController.text
                                else
                                  'amount':
                                      provider.state.productAmount ??
                                      widget.certificate.paymentAmount ??
                                      '',
                                'status': '2',
                                'retail_customer':
                                    provider.state.isRetailCustomer
                                    ? '001'
                                    : '',
                                'id': widget.certificate.id.toString(),
                                'certificate_id': widget.certificate.id
                                    .toString(),
                                'c_id': widget.certificate.id.toString(),
                              };

                              debugPrint(
                                "DEBUG: Submitting Role 2 Certificate Update",
                              );
                              debugPrint("DEBUG: Data Map Value: ${data}");
                              debugPrint(
                                "DEBUG: Data Map Keys: ${data.keys.toList()}",
                              );
                              debugPrint(
                                "DEBUG: Plate Image Path (from map): ${data['photo_path_plate']}",
                              );
                              debugPrint(
                                "DEBUG: Neck Image Path (from map): ${data['photo_path_neck']}",
                              );
                              debugPrint(
                                "DEBUG: Plate Image Path (from state): ${pickedImages['plate']}",
                              );

                              bool success = await provider
                                  .updateRole2Certificate(data, context);

                              if (success && context.mounted) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: FadeInUp(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(25),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                height: 70,
                                                width: 70,
                                                decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.check_circle_rounded,
                                                  color: Colors.green,
                                                  size: 40,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              const Text(
                                                "Success!",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              const Text(
                                                "Certificate updated successfully.",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 15,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 30),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      context,
                                                    ); // Close dialog
                                                    Navigator.pop(
                                                      context,
                                                    ); // Go back to list
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.primary,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 15,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    "OK",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: "Complete",
                            color: Colors.blueGrey,
                            onPressed: () => _showMissingFieldsPopup(context),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showMissingFieldsPopup(BuildContext context) {
    List<String> missing = [];
    if (selectedVehicleType == null) missing.add("Vehicle Type");

    final bool isCascade =
        selectedVehicleType?.toLowerCase().contains('cascade') ?? false;

    if (!isCascade) {
      if (selectedVehicleFormat == null) missing.add("Vehicle Format");
      if (vehicleNumberController.text.isEmpty) missing.add("Vehicle Number");
    } else {
      // In this screen, Cascade No is entered in vehicleNumberController
      if (vehicleNumberController.text.isEmpty) missing.add("Cascade Number");
    }
    if (selectedDealerId == null) missing.add("Dealer Name");
    if (mobileNumberController.text.isEmpty) missing.add("Mobile Number");
    if (serialNoController.text.isEmpty) missing.add("Cylinder Serial No");
    if (lastTestingDate == null) missing.add("Last Test Date");
    if (selectedCylinderMakeId == null) missing.add("Cylinder Make");
    if (manufacturingMonthController.text.isEmpty) missing.add("Mfg Month");
    if (manufacturingYearController.text.isEmpty) missing.add("Mfg Year");
    if (cceNoController.text.isEmpty) missing.add("CCE No");
    if (fillingPermDate == null) missing.add("Filling Permission Date");
    if (widget.certificate.workingPressure == null ||
        widget.certificate.workingPressure!.isEmpty)
      missing.add("Working Pressure");
    if (widget.certificate.testPressure == null ||
        widget.certificate.testPressure!.isEmpty)
      missing.add("Test Pressure");
    if (tareWeightController.text.isEmpty) missing.add("Original Tare Weight");
    if (actualWeightController.text.isEmpty) missing.add("Actual Weight");
    if (initialStatus == null) missing.add("Valve Inspection");
    if (visualStatus == null) missing.add("Visual Inspection");
    if (threadingStatus == null) missing.add("Cylinder Threading");
    if (internalStatus == null) missing.add("Internal Inspection");
    if (plateStatus == null) missing.add("Plate Status");
    if (cylinderSizeController.text.isEmpty) missing.add("Cylinder Size (Dia)");
    if (shellMinController.text.isEmpty) missing.add("Shell Min Thick");
    if (shellObsController.text.isEmpty) missing.add("Shell Obs Thick");
    if (bottomMinController.text.isEmpty) missing.add("Bottom Min Thick");
    if (bottomObsController.text.isEmpty) missing.add("Bottom Obs Thick");
    if (capacityController.text.isEmpty) missing.add("Water Capacity");
    if (expansionInitialController.text.isEmpty)
      missing.add("Initial Expansion");
    if (expansionTotalController.text.isEmpty) missing.add("Total Expansion");
    if (selectedResult == null) missing.add("Result");
    if (remarksController.text.isEmpty) missing.add("Remarks");

    // Photos - only if they are not already uploaded and not picked now
    if (!isCascade &&
        pickedImages["plate"] == null &&
        (widget.certificate.photoNumberPlate == null ||
            widget.certificate.photoNumberPlate!.isEmpty)) {
      missing.add("Number Plate Photo");
    }
    if (pickedImages["neck"] == null &&
        (widget.certificate.photoMarkingDetails == null ||
            widget.certificate.photoMarkingDetails!.isEmpty)) {
      missing.add("Cylinder Marking Photo");
    }

    if (missing.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: FadeInUp(
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Status",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "All fields are filled!",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "OK",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: FadeInUp(
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Missing Fields",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: missing
                            .map(
                              (f) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.redAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        f,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Continue",
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
          ),
        ),
      );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RowLabels extends StatelessWidget {
  final String l1, l2;
  const _RowLabels({required this.l1, required this.l2});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            l1,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            l2,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ValueBox extends StatelessWidget {
  final String text;
  const _ValueBox({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _DropDownField extends StatelessWidget {
  final String hint;
  final List<String> items;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  const _DropDownField({
    required this.hint,
    required this.items,
    required this.onChanged,
    this.validator,
    this.enabled = true,
  });
  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      builder: (FormFieldState<String> state) {
        final hasError = state.hasError;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: enabled ? Colors.white : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasError ? Colors.red : Colors.grey.withOpacity(0.3),
                  width: hasError ? 1.5 : 1.0,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text(
                    hint,
                    style: TextStyle(
                      fontSize: 14,
                      color: enabled ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  items: enabled
                      ? items
                          .map(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          )
                          .toList()
                      : null,
                  onChanged: enabled
                      ? (val) {
                          state.didChange(val);
                          onChanged(val);
                        }
                      : null,
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 12),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 11),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String? displayDate;
  final VoidCallback onTap;
  final String? Function(String?)? validator;
  const _DatePickerField({
    this.displayDate,
    required this.onTap,
    this.validator,
  });
  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      initialValue: displayDate,
      builder: (FormFieldState<String> state) {
        final hasError = state.hasError;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasError ? Colors.red : Colors.grey.withOpacity(0.3),
                    width: hasError ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayDate ?? "Select Date",
                        style: TextStyle(
                          fontSize: 14,
                          color: displayDate == null
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: hasError ? Colors.red : AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 12),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 11),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ManualField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? maxLength;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  const _ManualField({
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLines = 1,
    this.onChanged,
    this.validator,
    this.maxLength,
    this.enabled = true,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        counter: Container(),
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
