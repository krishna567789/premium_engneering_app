import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:premium_engneering_app/features/home/provider/home_state.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme.dart';
import '../../../widgets/custom_widgets.dart';
import '../../home/provider/home_provider.dart';
import '../../home/model/role1_certificate_list_model.dart';
import '../../auth/data/auth_repository.dart';
import '../../home/screens/role1_screen.dart';

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
  late TextEditingController vehicleNumberController,
      mobileNumberController,
      manufacturingMonthController,
      manufacturingYearController,
      expiryYearController,
      cascadeNoController,
      expansionInitialController,
      expansionTotalController,
      expansionPermController,
      expansionPctController,
      capacityController,
      retailCustNameController,
      cceNoController,
      initialObsController,
      visualObsController,
      threadingObsController,
      internalObsController,
      tareWeightController,
      actualWeightController,
      weightLossKgController,
      weightLossPctController,
      cylinderSizeController,
      shellMinController,
      shellObsController,
      bottomMinController,
      bottomObsController,
      remarksController,
      serialNoController,
      amountController;
  String? selectedResult,
      selectedVehicleType,
      selectedVehicleFormat,
      selectedDealer,
      selectedCylinderMakeName,
      selectedCylinderMakeId,
      testDate,
      collectionDate,
      nextTestDate,
      fillingPermDate,
      lastTestingDate,
      weightErrorMessage,
      shellThicknessError,
      bottomThicknessError,
      initialStatus,
      visualStatus,
      threadingStatus,
      internalStatus,
      plateStatus;
  int? selectedVehicleTypeId;
  dynamic selectedDealerId;
  bool _isPageLoading = true,
      isCylinderExpired = false,
      isEarlyTestingDetected = false,
      _hasManuallySetFillingPermDate = false,
      isVehicleWarning = false,
      isRemarkRequired = false;
  String? vehicleWarningMessage;
  Map<String, String?> pickedImages = {"plate": null, "neck": null};
  final FocusNode tareFocusNode = FocusNode(), actualFocusNode = FocusNode();
  late HomeProvider _homeProvider;

  bool get _isTestingBeforeMfg {
    if (lastTestingDate == null ||
        manufacturingMonthController.text.isEmpty ||
        manufacturingYearController.text.isEmpty)
      return false;
    try {
      final p = lastTestingDate!.split('-');
      if (p.length != 3) return false;
      int tM = int.parse(p[1]),
          tY = int.parse(p[2]),
          mY = int.parse(manufacturingYearController.text);
      const List<String> mN = [
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
      int mM = mN.indexOf(manufacturingMonthController.text) + 1;
      if (mM == 0) return false;
      return (tY < mY) || (tY == mY && tM < mM);
    } catch (_) {
      return false;
    }
  }

  void _checkShellThickness() {
    double? min = double.tryParse(shellMinController.text),
        obs = double.tryParse(shellObsController.text);
    setState(
      () => shellThicknessError = (min != null && obs != null && obs < min)
          ? "Observed thickness cannot be less than Minimum Calculate"
          : null,
    );
  }

  void _checkBottomThickness() {
    double? min = double.tryParse(bottomMinController.text),
        obs = double.tryParse(bottomObsController.text);
    setState(
      () => bottomThicknessError = (min != null && obs != null && obs < min)
          ? "Observed thickness cannot be less than Minimum Calculate"
          : null,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeProvider = context.read<HomeProvider>();
  }

  @override
  void initState() {
    super.initState();
    final cert = widget.certificate;
    tareFocusNode.addListener(() {
      if (!tareFocusNode.hasFocus) _triggerWeightWarning();
    });
    actualFocusNode.addListener(() {
      if (!actualFocusNode.hasFocus) _triggerWeightWarning();
    });
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
    amountController = TextEditingController(
      text: cert.retailerAmount ?? cert.paymentAmount ?? "",
    );
    initialStatus = cert.valveInspection == "0" ? "OK" : "Not OK";
    visualStatus = cert.visualInspection == "0" ? "OK" : "Not OK";
    threadingStatus = cert.cylinderThreading == "0" ? "OK" : "Not OK";
    internalStatus = cert.internalInspection == "0" ? "OK" : "Not OK";
    plateStatus = "OK";
    const List<String> mNames = [
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
    if (cert.manufacturingDate?.contains("-") ?? false) {
      final p = cert.manufacturingDate!.split("-");
      if (p[0].length == 4) {
        int? mIdx = int.tryParse(p[1]);
        manufacturingMonthController = TextEditingController(
          text: (mIdx != null && mIdx >= 1 && mIdx <= 12)
              ? mNames[mIdx - 1]
              : p[1],
        );
        manufacturingYearController = TextEditingController(text: p[0]);
      } else {
        int? mIdx = int.tryParse(p[0]);
        manufacturingMonthController = TextEditingController(
          text: (mIdx != null && mIdx >= 1 && mIdx <= 12)
              ? mNames[mIdx - 1]
              : p[0],
        );
        manufacturingYearController = TextEditingController(text: p[1]);
      }
    } else {
      manufacturingMonthController = TextEditingController();
      manufacturingYearController = TextEditingController();
    }
    String iExp = cert.expireDate ?? "";
    if (iExp.contains("-")) {
      final p = iExp.split("-");
      if (p[0].length == 4) iExp = "${p[1]}-${p[0]}";
    }
    expiryYearController = TextEditingController(text: iExp);
    final isRet =
        (cert.dealerId == 'rc01' ||
        cert.dealerId == 'rc001' ||
        cert.dealerId == 0 ||
        cert.dealerId == '0' ||
        cert.dealerName == "Retail Customer");
    selectedVehicleType = cert.vehicalType;
    selectedVehicleTypeId = int.tryParse(cert.vehicalType ?? "");
    selectedVehicleFormat = cert.vehicleFormat;
    selectedCylinderMakeName = cert.cylinderMake;
    selectedCylinderMakeId = cert.cylinderMake;
    selectedDealer = isRet ? "Retail Customer" : cert.dealerName;
    selectedDealerId = isRet ? 'rc01' : cert.dealerId;
    retailCustNameController = TextEditingController(
      text: isRet ? cert.dealerName : "",
    );
    if (cert.collectionDate?.contains("-") ?? false) {
      final p = cert.collectionDate!.split("-");
      collectionDate = p[0].length == 4
          ? "${p[2]}-${p[1]}-${p[0]}"
          : cert.collectionDate;
    }
    if (cert.testDate?.contains("-") ?? false) {
      final p = cert.testDate!.split("-");
      testDate = p[0].length == 4 ? "${p[2]}-${p[1]}-${p[0]}" : cert.testDate;
    }
    if (cert.nextTestDate?.contains("-") ?? false) {
      final p = cert.nextTestDate!.split("-");
      nextTestDate = p[0].length == 4
          ? "${p[2]}-${p[1]}-${p[0]}"
          : cert.nextTestDate;
    }
    if (cert.lastTestDate?.contains("-") ?? false) {
      final p = cert.lastTestDate!.split("-");
      lastTestingDate = p[0].length == 4
          ? "${p[2]}-${p[1]}-${p[0]}"
          : cert.lastTestDate;
    }
    if (cert.fillingPermissionDate?.isNotEmpty ?? false) {
      if (cert.fillingPermissionDate!.contains("-")) {
        final p = cert.fillingPermissionDate!.split("-");
        fillingPermDate = (p.isNotEmpty && p[0].length == 4)
            ? "${p[2]}-${p[1]}-${p[0]}"
            : cert.fillingPermissionDate;
      } else
        fillingPermDate = cert.fillingPermissionDate;
      _hasManuallySetFillingPermDate = true;
    } else {
      if (manufacturingMonthController.text.isNotEmpty &&
          manufacturingYearController.text.isNotEmpty) {
        int mIdx = mNames.indexOf(manufacturingMonthController.text);
        if (mIdx != -1)
          fillingPermDate =
              "01-${(mIdx + 1).toString().padLeft(2, '0')}-${manufacturingYearController.text}";
      }
      _hasManuallySetFillingPermDate = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<HomeProvider>();
      provider.setIsRetailCustomer(isRet);
      final dId = isRet ? 'rc01' : (selectedDealerId?.toString() ?? '');
      provider.getVehicleFormat();
      provider.getDealerType();
      provider.getCylinderMake();
      await provider.loadHomeData();
      String? cPId;
      if (provider.state.homeData?.data != null) {
        try {
          final p = provider.state.homeData!.data!.firstWhere(
            (x) =>
                x.fullname?.trim().toLowerCase() ==
                    cert.productType?.trim().toLowerCase() &&
                x.standard?.trim().toLowerCase() ==
                    cert.specification?.trim().toLowerCase(),
          );
          provider.setSelectedProduct(p);
          cPId = p.id?.toString();
        } catch (_) {
          if (provider.state.homeData!.data!.isNotEmpty) {
            final p = provider.state.homeData!.data!.first;
            provider.setSelectedProduct(p);
            cPId = p.id?.toString();
          }
        }
      }
      await provider.getVehicleType(dId, productId: cPId);
      if (selectedVehicleType != null &&
          provider.state.vehicleTypeData?.data != null) {
        try {
          final m = provider.state.vehicleTypeData!.data!.firstWhere(
            (e) =>
                e.vehicleName?.trim().toLowerCase() ==
                    selectedVehicleType?.trim().toLowerCase() ||
                e.id.toString() == selectedVehicleType?.trim(),
          );
          if (mounted)
            setState(() {
              selectedVehicleTypeId = m.id;
              selectedVehicleType = m.vehicleName;
            });
        } catch (e) {
          debugPrint("Role2Edit: Could not match vehicle type: $e");
        }
      }
      if (selectedVehicleTypeId != null && cPId != null)
        provider.getProductAmountByDealer({
          'dealer_id': dId,
          'vehicle_id': selectedVehicleTypeId.toString(),
          'product_id': cPId,
        });
      if (mounted) setState(() => _isPageLoading = false);
      _syncExpiryDate();
    });
  }

  @override
  void dispose() {
    tareFocusNode.dispose();
    actualFocusNode.dispose();
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
    _homeProvider.clearProductAmount();
    _homeProvider.clearDealerAmount();
    super.dispose();
  }

  void _syncExpiryDate() {
    final year = int.tryParse(manufacturingYearController.text);
    if (year != null && manufacturingMonthController.text.isNotEmpty) {
      const List<String> mNames = [
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
      int mIdx = mNames.indexOf(manufacturingMonthController.text);
      if (mIdx != -1) {
        final lifeY =
            context
                .read<HomeProvider>()
                .state
                .homeData
                ?.data
                ?.firstOrNull
                ?.lifeOfCylinder ??
            20;
        int eYear = year + lifeY;
        String m = (mIdx + 1).toString().padLeft(2, '0');
        DateTime now = DateTime.now();
        bool expired =
            (eYear < now.year) || (eYear == now.year && (mIdx + 1) < now.month);
        setState(() {
          expiryYearController.text = "$m-$eYear";
          isCylinderExpired = expired;
        });
        if (expired)
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _showExpiredWarningDialog(),
          );
      }
    }
  }

  void _showExpiredWarningDialog() {
    final theme = Theme.of(context);
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
              backgroundColor: theme.colorScheme.primary,
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
      final p = expiryYearController.text.split("-");
      if (p.length >= 2) {
        int? mI = int.tryParse(p[0]);
        if (mI != null && mI >= 1 && mI <= 12) {
          const List<String> mN = [
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
          return "${mN[mI - 1]} ${p[1]}";
        }
      }
      return expiryYearController.text;
    } catch (_) {
      return expiryYearController.text;
    }
  }

  void _syncFillingPermDate() {
    if (manufacturingMonthController.text.isNotEmpty &&
        manufacturingYearController.text.isNotEmpty) {
      const List<String> mN = [
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
      int mIdx = mN.indexOf(manufacturingMonthController.text);
      if (mIdx != -1 && !_hasManuallySetFillingPermDate)
        setState(
          () => fillingPermDate =
              "01-${(mIdx + 1).toString().padLeft(2, '0')}-${manufacturingYearController.text}",
        );
    }
  }

  Future<void> _checkVehicleNumber(String vNo) async {
    if (vNo.isEmpty) return;
    try {
      final auth = context.read<AuthRepository>();
      final userId = await auth.getUserId();
      final adminId = await auth.getAdminId();
      final prov = context.read<HomeProvider>();
      final iC = prov.state.homeData?.data?.firstOrNull?.intervalTesting ?? 3;
      final now = DateTime.now();
      final fallback =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      await prov.checkVehicleNumber({
        'vehicleno': vNo,
        'userid': userId ?? '',
        'admin_id': adminId ?? '',
        'intervel_count': iC.toString(),
        'collection_date': (collectionDate?.isNotEmpty ?? false)
            ? collectionDate!
            : fallback,
        'vehicle_type_id': selectedVehicleTypeId?.toString() ?? '',
        'product_id': prov.state.selectedProduct?.id?.toString() ?? '',
      });
      final resp = prov.state.vehicleCheckData;
      if (resp != null) {
        final s = resp['status'];
        final m = resp['message']?.toString() ?? '';
        final isW =
            s == true ||
            s == 'true' ||
            s == 1 ||
            s.toString().toLowerCase() == 'success';
        if (isW && m.isNotEmpty) {
          if (mounted) {
            setState(() {
              isVehicleWarning = true;
              vehicleWarningMessage = m;
              isRemarkRequired = true;
            });
            _showVehicleWarningDialog(m);
          }
        } else {
          if (mounted)
            setState(() {
              isVehicleWarning = false;
              vehicleWarningMessage = null;
              isRemarkRequired = false;
            });
        }
      }
    } catch (e) {
      debugPrint('Role2 edit vehicle check error: $e');
    }
  }

  void _showVehicleWarningDialog(String m) {
    setState(() {
      isRemarkRequired = true;
      remarksController.text = m;
    });
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
        content: Text(m, style: const TextStyle(fontSize: 15)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
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
        manufacturingYearController.text.isEmpty)
      return;
    try {
      final p = testDate!.split("-");
      if (p.length != 3) return;
      final tDT = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
      const List<String> mN = [
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
      int mIdx = mN.indexOf(manufacturingMonthController.text);
      if (mIdx == -1) return;
      int mY = int.parse(manufacturingYearController.text);
      final iT =
          context
              .read<HomeProvider>()
              .state
              .homeData
              ?.data
              ?.firstOrNull
              ?.intervalTesting ??
          3;
      if (tDT.isBefore(DateTime(mY + iT, mIdx + 1, 1))) {
        setState(() => isEarlyTestingDetected = true);
        _showEarlyTestingDialog();
      } else
        setState(() => isEarlyTestingDetected = false);
    } catch (e) {
      debugPrint("Error checking interval: $e");
    }
  }

  void _showEarlyTestingDialog() {
    const String message = "You’ve come in for testing earlier than the scheduled interval. If you proceed, you must provide a reason in the Remarks field below.";
    setState(() {
      isRemarkRequired = true;
      remarksController.text = message;
    });
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
          message,
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
    double o = double.tryParse(tareWeightController.text) ?? 0.0;
    double a = double.tryParse(actualWeightController.text) ?? 0.0;
    if (o > 0 && a > 0) {
      double l = o - a;
      double lP = (l / o) * 100;
      setState(() {
        weightLossKgController.text = l.toStringAsFixed(3);
        weightLossPctController.text = lP.toStringAsFixed(2);
        weightErrorMessage = lP > 5.0
            ? "Loss of weight exceeds 5%. Cylinder may be rejected."
            : null;
      });
    }
  }

  void _triggerWeightWarning() {
    _calculateWeightLoss();
    if (weightErrorMessage != null)
      _showWeightWarningDialog(weightErrorMessage!);
  }

  void _showWeightWarningDialog(String m) {
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
        content: Text(m, style: const TextStyle(fontSize: 15)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
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
    double c1 = double.tryParse(expansionInitialController.text) ?? 0.0,
        c2 = double.tryParse(expansionTotalController.text) ?? 0.0,
        c3 = double.tryParse(expansionPermController.text) ?? 0.0;
    if (c1 != 0 || c2 != 0 || c3 != 0) {
      if ((c2 - c1) != 0) {
        double p = ((c3 - c1) / (c2 - c1)) * 100;
        setState(() {
          expansionPctController.text = p.toStringAsFixed(2);
          selectedResult = p > 10.0 ? "FAIL" : "PASS";
        });
      }
    } else
      setState(() => expansionPctController.text = "");
  }

  Future<void> _pickAndCompressImage(String tag) async {
    final picker = ImagePicker();
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
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
    if (src == null) return;
    final img = await picker.pickImage(source: src);
    if (img != null) setState(() => pickedImages[tag] = img.path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String? formatD(String? s) {
      if (s?.contains("-") ?? false) {
        final p = s!.split("-");
        return p[0].length == 4 ? "${p[2]}-${p[1]}-${p[0]}" : s;
      }
      return s;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Update Certificate",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
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
      body: _isPageLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
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
                          const _RowLabels(
                            l1: "License Name",
                            l2: "Approval No",
                          ),
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
                        final vTypes =
                            provider.state.vehicleTypeData?.data ?? [];
                        final types = vTypes
                            .map((e) => e.vehicleName ?? "")
                            .toList();
                        String resType = selectedVehicleType ?? "";
                        try {
                          final m = vTypes.firstWhere(
                            (e) =>
                                e.id.toString() == resType ||
                                e.vehicleName == resType,
                          );
                          resType = m.vehicleName ?? resType;
                        } catch (_) {}
                        bool isCasc = resType.toLowerCase().contains('cascade');
                        bool isCNG =
                            provider.state.selectedProduct?.fullname
                                ?.toLowerCase()
                                .contains('cng') ??
                            false;
                        return _buildActionCard(
                          child: Column(
                            children: [
                              Consumer<HomeProvider>(
                                builder: (context, p, _) {
                                  final dL = p.state.dealerTypeData?.data ?? [];
                                  final dealers = [
                                    "Retail Customer",
                                    ...dL.map((e) => e.fullname ?? ""),
                                  ];
                                  final isR = p.state.isRetailCustomer;
                                  String dV = (selectedDealer?.isEmpty ?? true)
                                      ? "Select Dealer"
                                      : selectedDealer!;
                                  if (selectedDealerId != null) {
                                    try {
                                      final m = dL.firstWhere(
                                        (e) =>
                                            e.id?.toString() ==
                                            selectedDealerId?.toString(),
                                      );
                                      dV = m.fullname ?? dV;
                                    } catch (_) {}
                                  }
                                  return Column(
                                    children: [
                                      _RowLabels(
                                        l1: "Choose Dealer",
                                        l2: isR
                                            ? "Retail Customer Name"
                                            : "Mobile Number",
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: _DropDownField(
                                              enabled: !isR,
                                              hint: dV,
                                              items: dealers,
                                              validator: (v) =>
                                                  (selectedDealer == null)
                                                  ? ""
                                                  : null,
                                              onChanged: (val) {
                                                if (val == null ||
                                                    val == "Retail Customer") {
                                                  p.setIsRetailCustomer(true);
                                                  setState(() {
                                                    selectedDealer = val;
                                                    selectedDealerId = 'rc01';
                                                    mobileNumberController
                                                        .clear();
                                                  });
                                                  p.clearDealerAmount();
                                                  p.clearProductAmount();
                                                  p.getVehicleType(
                                                    'rc01',
                                                    productId: p
                                                        .state
                                                        .selectedProduct
                                                        ?.id
                                                        ?.toString(),
                                                  );
                                                  return;
                                                }
                                                try {
                                                  final sel = dL.firstWhere(
                                                    (e) => e.fullname == val,
                                                  );
                                                  final ret = val
                                                      .toLowerCase()
                                                      .contains('retail');
                                                  p.setIsRetailCustomer(ret);
                                                  setState(() {
                                                    selectedDealer = val;
                                                    selectedDealerId = sel.id;
                                                    if (!ret)
                                                      mobileNumberController
                                                              .text =
                                                          sel.mobileNo ?? '';
                                                  });
                                                  if (ret) {
                                                    p.clearDealerAmount();
                                                    p.clearProductAmount();
                                                    p.getVehicleType(
                                                      'rc01',
                                                      productId: p
                                                          .state
                                                          .selectedProduct
                                                          ?.id
                                                          ?.toString(),
                                                    );
                                                  } else if (sel.id != null) {
                                                    p.getVehicleType(
                                                      sel.id.toString(),
                                                      productId: p
                                                          .state
                                                          .selectedProduct
                                                          ?.id
                                                          ?.toString(),
                                                    );
                                                    p.getProductAmountByDealer({
                                                      'dealer_id': sel.id
                                                          .toString(),
                                                      'vehicle_id':
                                                          selectedVehicleTypeId
                                                              ?.toString() ??
                                                          '',
                                                      'product_id':
                                                          p
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
                                          Expanded(
                                            child: _ManualField(
                                              hint: isR
                                                  ? "Enter Customer Name"
                                                  : "Mobile",
                                              controller: isR
                                                  ? retailCustNameController
                                                  : mobileNumberController,
                                              keyboardType: isR
                                                  ? TextInputType.text
                                                  : TextInputType.phone,
                                              validator: (v) {
                                                if (v == null || v.isEmpty)
                                                  return "Required";
                                                if (!isR && v.length != 10)
                                                  return "10 digits required";
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isR)
                                        Column(
                                          children: [
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
                                                    controller:
                                                        amountController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                    ],
                                                    validator: (v) =>
                                                        (isR &&
                                                            (v == null ||
                                                                v.isEmpty))
                                                        ? "Required"
                                                        : null,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: _ManualField(
                                                    hint: "Enter Mobile Number",
                                                    controller:
                                                        mobileNumberController,
                                                    keyboardType:
                                                        TextInputType.phone,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                      LengthLimitingTextInputFormatter(
                                                        10,
                                                      ),
                                                    ],
                                                    validator: (v) {
                                                      if (v == null ||
                                                          v.isEmpty)
                                                        return "Required";
                                                      if (v.length != 10)
                                                        return "Must be 10 digits";
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 15),
                              _RowLabels(
                                l1: "Vehicle Type${selectedVehicleType != null && selectedVehicleType!.isNotEmpty ? " : $selectedVehicleType" : ""}",
                                l2: (collectionDate?.isNotEmpty ?? false)
                                    ? "Collection date"
                                    : "",
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _DropDownField(
                                      hint: resType.isEmpty
                                          ? "Select Type"
                                          : resType,
                                      items: types,
                                      validator: (v) =>
                                          (selectedVehicleType == null)
                                          ? ""
                                          : null,
                                      onChanged: (val) {
                                        try {
                                          final sel = vTypes.firstWhere(
                                            (e) => e.vehicleName == val,
                                          );
                                          setState(() {
                                            selectedVehicleType = val;
                                            selectedVehicleTypeId = sel.id;
                                          });
                                          final dId =
                                              provider.state.isRetailCustomer
                                              ? '0'
                                              : selectedDealerId?.toString();
                                          if (sel.id != null && dId != null)
                                            provider.getProductAmountByDealer({
                                              'dealer_id': dId,
                                              'vehicle_id': sel.id.toString(),
                                              'product_id':
                                                  provider
                                                      .state
                                                      .selectedProduct
                                                      ?.id
                                                      ?.toString() ??
                                                  '',
                                            });
                                        } catch (_) {}
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  if (collectionDate?.isNotEmpty ?? false)
                                    Expanded(
                                      child: _DatePickerField(
                                        displayDate: formatD(collectionDate),
                                        validator: (v) =>
                                            (collectionDate == null)
                                            ? ""
                                            : null,
                                        onTap: () async {
                                          final d = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime.now(),
                                          );
                                          if (d != null)
                                            setState(
                                              () => collectionDate =
                                                  "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}",
                                            );
                                        },
                                      ),
                                    )
                                  else
                                    const Expanded(child: SizedBox()),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Consumer<HomeProvider>(
                                builder: (context, p, _) {
                                  if (p.state.productAmountStatus ==
                                          HomeStatus.success &&
                                      p.state.productAmount != null &&
                                      selectedVehicleTypeId != null) {
                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme
                                            .inputDecorationTheme
                                            .fillColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Product Amount: ₹ ${p.state.productAmount}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          if (p.state.totalDuesPending != null)
                                            Text(
                                              "Total Dues Pending: ₹ ${p.state.totalDuesPending}",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                              const SizedBox(height: 15),
                              if (isCasc)
                                Column(
                                  children: [
                                    const _RowLabels(
                                      l1: "Enter Cascade Number",
                                      l2: "",
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _ManualField(
                                            hint: "Enter Cascade Number",
                                            controller: cascadeNoController,
                                            validator: (v) =>
                                                (v == null || v.isEmpty)
                                                ? ""
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Expanded(child: SizedBox()),
                                      ],
                                    ),
                                  ],
                                )
                              else if (isCNG)
                                Column(
                                  children: [
                                    const _RowLabels(
                                      l1: "Choose Vehicle Format",
                                      l2: "Add Vehicle Number",
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Consumer<HomeProvider>(
                                            builder: (context, p, _) {
                                              final fm =
                                                  p
                                                      .state
                                                      .vehicleFormatData
                                                      ?.data
                                                      ?.map(
                                                        (e) => e.vFormat ?? "",
                                                      )
                                                      .toList() ??
                                                  [];
                                              return _DropDownField(
                                                hint:
                                                    selectedVehicleFormat ??
                                                    "Format",
                                                items: fm,
                                                validator: (v) => isCasc
                                                    ? null
                                                    : (selectedVehicleFormat ==
                                                              null
                                                          ? ""
                                                          : null),
                                                onChanged: (v) => setState(
                                                  () =>
                                                      selectedVehicleFormat = v,
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
                                            validator: (v) => isCasc
                                                ? null
                                                : (v == null || v.isEmpty
                                                      ? ""
                                                      : null),
                                            textCapitalization:
                                                TextCapitalization.characters,
                                            keyboardType:
                                                (selectedVehicleFormat
                                                        ?.toUpperCase()
                                                        .contains('X') ??
                                                    true)
                                                ? TextInputType.visiblePassword
                                                : TextInputType.number,
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                selectedVehicleFormat?.length ??
                                                    13,
                                              ),
                                              VehicleNumberSmartFormatter(
                                                selectedVehicleFormat,
                                              ),
                                            ],
                                            onChanged: (v) {
                                              if (v.length >= 6)
                                                _checkVehicleNumber(v);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 15),
                              const _RowLabels(
                                l1: "Test Date",
                                l2: "Next Test Due Date",
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _DatePickerField(
                                      displayDate: formatD(testDate),
                                      validator: (v) =>
                                          (testDate == null) ? "" : null,
                                      onTap: () async {
                                        final d = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime.now(),
                                        );
                                        if (d != null) {
                                          setState(() {
                                            testDate =
                                                "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
                                            final iT =
                                                context
                                                    .read<HomeProvider>()
                                                    .state
                                                    .homeData
                                                    ?.data
                                                    ?.firstOrNull
                                                    ?.intervalTesting ??
                                                3;
                                            final nD = DateTime(
                                              d.year + iT,
                                              d.month,
                                              d.day,
                                            ).subtract(const Duration(days: 1));
                                            nextTestDate =
                                                "${nD.day.toString().padLeft(2, '0')}-${nD.month.toString().padLeft(2, '0')}-${nD.year}";
                                            _checkIntervalWarning();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _ValueBox(
                                      text:
                                          formatD(nextTestDate) ??
                                          "Auto Calculated",
                                    ),
                                  ),
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
                                  text:
                                      widget.certificate.specification ?? "N/A",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          const _RowLabels(
                            l1: "Serial Cylinder No:",
                            l2: "Manufacturing Date",
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
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _DatePickerField(
                                        showIcon: false,
                                        displayDate:
                                            manufacturingMonthController
                                                .text
                                                .isEmpty
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
                                              const List<String> mN = [
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
                                                title: const Text(
                                                  "Select Month",
                                                ),
                                                content: SizedBox(
                                                  width: 300,
                                                  height: 300,
                                                  child: ListView.builder(
                                                    itemCount: 12,
                                                    itemBuilder: (context, i) {
                                                      final mNm = mN[i];
                                                      final now =
                                                          DateTime.now();
                                                      int? sY = int.tryParse(
                                                        manufacturingYearController
                                                            .text,
                                                      );
                                                      bool isF =
                                                          (sY == now.year &&
                                                          (i + 1) > now.month);
                                                      return ListTile(
                                                        title: Text(
                                                          mNm,
                                                          style: TextStyle(
                                                            color: isF
                                                                ? Colors.grey
                                                                : theme
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.color,
                                                          ),
                                                        ),
                                                        enabled: !isF,
                                                        onTap: isF
                                                            ? null
                                                            : () {
                                                                setState(() {
                                                                  manufacturingMonthController
                                                                          .text =
                                                                      mNm;
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
                                        showIcon: false,
                                        displayDate:
                                            manufacturingYearController
                                                .text
                                                .isEmpty
                                            ? "Year"
                                            : manufacturingYearController.text,
                                        validator: (v) =>
                                            (manufacturingYearController
                                                .text
                                                .isEmpty)
                                            ? " "
                                            : null,
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text(
                                                  "Select Year",
                                                ),
                                                content: SizedBox(
                                                  width: 300,
                                                  height: 300,
                                                  child: YearPicker(
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime.now(),
                                                    selectedDate:
                                                        DateTime.now(),
                                                    onChanged: (dt) {
                                                      setState(() {
                                                        manufacturingYearController
                                                            .text = dt.year
                                                            .toString();
                                                        if (dt.year ==
                                                            DateTime.now()
                                                                .year) {
                                                          const List<String>
                                                          mN = [
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
                                                          int mIdx = mN.indexOf(
                                                            manufacturingMonthController
                                                                .text,
                                                          );
                                                          if (mIdx + 1 >
                                                              DateTime.now()
                                                                  .month)
                                                            manufacturingMonthController
                                                                    .text =
                                                                "";
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
                            l1: "Cylinder Make",
                            l2: "Last Testing Date",
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 3,
                                child: Consumer<HomeProvider>(
                                  builder: (context, p, _) {
                                    final d =
                                        p.state.cylinderMakeData?.data ?? [];
                                    final its = d
                                        .map((e) => e.fullname ?? "")
                                        .toList();
                                    String dV =
                                        selectedCylinderMakeName ?? "Select";
                                    try {
                                      final m = d.firstWhere(
                                        (e) =>
                                            e.id.toString() == dV ||
                                            e.fullname == dV,
                                      );
                                      dV = m.fullname ?? dV;
                                    } catch (_) {}
                                    return _DropDownField(
                                      hint: dV,
                                      items: its,
                                      validator: (v) =>
                                          (selectedCylinderMakeId == null)
                                          ? ""
                                          : null,
                                      onChanged: (v) {
                                        final sel = d.firstWhere(
                                          (e) => e.fullname == v,
                                        );
                                        setState(() {
                                          selectedCylinderMakeName = v;
                                          selectedCylinderMakeId = sel.id
                                              ?.toString();
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _DatePickerField(
                                  displayDate: formatD(lastTestingDate),
                                  validator: (v) =>
                                      (lastTestingDate == null) ? "" : null,
                                  onTap: () async {
                                    final d = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );
                                    if (d != null)
                                      setState(
                                        () => lastTestingDate =
                                            "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}",
                                      );
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (_isTestingBeforeMfg)
                            const Padding(
                              padding: EdgeInsets.only(top: 4, left: 12),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Last testing date cannot be before manufacturing date.",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
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
                                  displayDate: formatD(fillingPermDate),
                                  validator: (v) =>
                                      (fillingPermDate == null) ? "" : null,
                                  onTap: () async {
                                    final d = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );
                                    if (d != null)
                                      setState(() {
                                        fillingPermDate =
                                            "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
                                        _hasManuallySetFillingPermDate = true;
                                      });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Text(
                                "Expiry Date",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodyLarge?.color,
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
                                child: _ValueBox(
                                  text: _getFormattedExpiryDate(),
                                ),
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
                                    focusNode: tareFocusNode,
                                    validator: (v) =>
                                        (v == null || v.isEmpty) ? "" : null,
                                    onChanged: (_) => _calculateWeightLoss(),
                                    onFieldSubmitted: (_) =>
                                        _triggerWeightWarning(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _ManualField(
                                    hint: "Actual Weight",
                                    controller: actualWeightController,
                                    focusNode: actualFocusNode,
                                    validator: (v) =>
                                        (v == null || v.isEmpty) ? "" : null,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => _calculateWeightLoss(),
                                    onFieldSubmitted: (_) =>
                                        _triggerWeightWarning(),
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
                                    onChanged: (v) =>
                                        setState(() => plateStatus = v),
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
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Shell (mm)",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const _RowLabels(
                              l1: "Minimum Calculate",
                              l2: "Observed Thickness",
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _ManualField(
                                    hint: "Minimum Calculate",
                                    keyboardType: TextInputType.number,
                                    controller: shellMinController,
                                    onChanged: (_) => _checkShellThickness(),
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
                                    onChanged: (_) => _checkShellThickness(),
                                    validator: (v) =>
                                        (v == null || v.isEmpty) ? "" : null,
                                  ),
                                ),
                              ],
                            ),
                            if (shellThicknessError != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                  left: 12,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    shellThicknessError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 15),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Thickness of the Center of the Bottom",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodySmall?.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const _RowLabels(
                              l1: "Minimum Calculate",
                              l2: "Observed Thickness",
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _ManualField(
                                    hint: "Minimum Calculate",
                                    controller: bottomMinController,
                                    onChanged: (_) => _checkBottomThickness(),
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
                                    onChanged: (_) => _checkBottomThickness(),
                                    validator: (v) =>
                                        (v == null || v.isEmpty) ? "" : null,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            if (bottomThicknessError != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                  left: 12,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    bottomThicknessError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
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
                                    text:
                                        widget.certificate.workingPressure ??
                                        "204",
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
                                    text:
                                        widget.certificate.testPressure ??
                                        "340",
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
                            const _RowLabels(
                              l1: "Permanent Exp (%)",
                              l2: "Result",
                            ),
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

                    if (widget.certificate.productType == "CNG") ...[
                      _buildSectionHeader("Photo Uploads"),

                      _buildActionCard(
                        child: Column(
                          children: [
                            DashedUploadArea(
                              title: "Update Photo of Number Plate",
                              onPick: () => _pickAndCompressImage("plate"),
                              imagePath: pickedImages["plate"],
                              networkImageUrl:
                                  (widget
                                          .certificate
                                          .photoNumberPlate
                                          ?.isNotEmpty ??
                                      false)
                                  ? "https://pe.microcmd.com/API/uploads/${widget.certificate.photoNumberPlate}"
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            DashedUploadArea(
                              title: "Update Photo of Cylinder Marking",
                              onPick: () => _pickAndCompressImage("neck"),
                              imagePath: pickedImages["neck"],
                              networkImageUrl:
                                  (widget
                                          .certificate
                                          .photoMarkingDetails
                                          ?.isNotEmpty ??
                                      false)
                                  ? "https://pe.microcmd.com/API/uploads/${widget.certificate.photoMarkingDetails}"
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                    ...[
                      _buildSectionHeader("Photo Uploads"),
                      if (widget.certificate.productType == 'Oxygen')
                        DashedUploadArea(
                          title: "Update Photo of Cylinder Marking",
                          onPick: () => _pickAndCompressImage("neck"),
                          imagePath: pickedImages["neck"],
                          networkImageUrl:
                              (widget
                                      .certificate
                                      .photoMarkingDetails
                                      ?.isNotEmpty ??
                                  false)
                              ? "https://pe.microcmd.com/API/uploads/${widget.certificate.photoMarkingDetails}"
                              : null,
                        ),
                    ],

                    if (isRemarkRequired) ...[
                      _buildSectionHeader("Remarks"),
                      _buildActionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isEarlyTestingDetected)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 6),
                                child: Text(
                                  "Early testing detected. Reason is required.",
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            _ManualField(
                              hint: "Remarks",
                              controller: remarksController,
                              validator: (v) {
                                if (isEarlyTestingDetected &&
                                    (v == null || v.trim().isEmpty))
                                  return "As you are performing an early test, please specify the reason in the Remarks field.";
                                return null;
                              },
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                    Consumer<HomeProvider>(
                      builder: (context, prov, _) {
                        return SafeArea(
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: "Update Certificate",
                                  color: Colors.green,
                                  isLoading:
                                      prov.state.certificateStatus ==
                                      HomeStatus.loading,
                                  onPressed: () async {
                                    await _submitCertificateUpdate(
                                      context,
                                      prov,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomButton(
                                  text: "Complete",
                                  color: Colors.blueGrey,
                                  onPressed: () =>
                                      _showMissingFieldsPopup(context, prov),
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

  Future<void> _submitCertificateUpdate(
    BuildContext context,
    HomeProvider prov,
  ) async {
    final theme = Theme.of(context);
    final auth = context.read<AuthRepository>();
    final uId = await auth.getUserId();
    final Map<String, dynamic> d = {
      'dealer_name': prov.state.isRetailCustomer
          ? 'rc01'
          : (selectedDealerId?.toString() ?? ''),
      'dealer': prov.state.isRetailCustomer
          ? 'rc01'
          : (selectedDealerId?.toString() ?? ''),
      'photo_number_plate': pickedImages['plate'],
      'photo_marking_details': pickedImages['neck'],
      'adminid': widget.certificate.adminId?.toString() ?? '',
      'license_name': 'PREMIUM HYDRO ENGINEERING',
      'approval_no': 'AG/HQ/GJ/GCT/1G49051',
      'vehicle_type': '${selectedVehicleTypeId ?? selectedVehicleType ?? ''}',
      'display_number':
          '${widget.certificate.displayNumber ?? vehicleNumberController.text}',
      'vehicle_number': '${vehicleNumberController.text}',
      'vehicle_format': '${selectedVehicleFormat ?? ''}',
      'cascade_no': '${cascadeNoController.text}',
      'test_date': '${testDate ?? ''}',
      'collection_date': '${collectionDate ?? ''}',
      'next_test_date': '${nextTestDate ?? ''}',
      'product_type': 'Compress Natural Gas',
      'specification': 'IS 15490',
      'cylinder_serial_no': '${serialNoController.text}',
      'last_test_date': lastTestingDate,
      'cylinder_make': '${selectedCylinderMakeId ?? ''}',
      'manufacturing_date':
          '${() {
            const List<String> mN = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
            String mS = manufacturingMonthController.text.trim();
            int mI = mN.indexOf(mS);
            return '${(mI != -1 ? mI + 1 : 1).toString().padLeft(2, '0')}-${manufacturingYearController.text}';
          }()}',
      'cce_filling_permission_no': '${cceNoController.text}',
      'filling_permission_date': '${fillingPermDate ?? ''}',
      'expire_date': expiryYearController.text,
      'valve_inspection': '${initialStatus == "OK" ? "0" : "1"}',
      'valve_inspection_remark': initialObsController.text,
      'visual_inspection': '${visualStatus == "OK" ? "0" : "1"}',
      'visual_inspection_remark': visualObsController.text,
      'cylinder_threading': '${threadingStatus == "OK" ? "0" : "1"}',
      'cylinder_threading_remark': threadingObsController.text,
      'internal_inspection': '${internalStatus == "OK" ? "0" : "1"}',
      'internal_inspection_remark': internalObsController.text,
      'original_tare_weight': tareWeightController.text,
      'actual_weight': actualWeightController.text,
      'loss_of_weight': weightLossKgController.text,
      'loss_of_weight_percentage': weightLossPctController.text,
      'painting': '0',
      'die_of_cylinder': cylinderSizeController.text,
      'shell_min_cal_thick': shellMinController.text,
      'shell_obs_thick_min': shellObsController.text,
      'bottom_min_cal_thick': bottomMinController.text,
      'bottom_obs_thick_min': bottomObsController.text,
      'water_capacity': capacityController.text,
      'working_pressure': (widget.certificate.workingPressure ?? '').toString(),
      'test_pressure': (widget.certificate.testPressure ?? '340').toString(),
      'initial_expansion': expansionInitialController.text,
      'total_expansion': expansionTotalController.text,
      'permanent_expansion': expansionPermController.text,
      'permanent_expansion_percentage': expansionPctController.text,
      'result': selectedResult ?? 'PASS',
      'remark': remarksController.text,
      'userid': uId ?? '',
      if (prov.state.isRetailCustomer)
        'retail_cust_name': retailCustNameController.text,
      'mobile_no': mobileNumberController.text,
      if (prov.state.isRetailCustomer)
        'retail_amount': amountController.text
      else
        'amount':
            prov.state.productAmount ?? widget.certificate.paymentAmount ?? '',
      'status': '2',
      'retail_customer': prov.state.isRetailCustomer ? '001' : '',
      'id': widget.certificate.id.toString(),
      'certificate_id': widget.certificate.id.toString(),
      'c_id': widget.certificate.id.toString(),
    };
    bool success = await prov.updateRole2Certificate(d, context);
    if (success && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => GlassDialog(
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
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Success!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Certificate updated successfully.",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
    }
  }

  void _showMissingFieldsPopup(BuildContext context, HomeProvider prov) {
    List<String> missing = [];
    if (selectedVehicleType == null) missing.add("Vehicle Type");
    final bool isC =
        selectedVehicleType?.toLowerCase().contains('cascade') ?? false;
    if (!isC) {
      if (selectedVehicleFormat == null) missing.add("Vehicle Format");
      if (vehicleNumberController.text.isEmpty) missing.add("Vehicle Number");
    } else {
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
    if (widget.certificate.workingPressure?.isEmpty ?? true)
      missing.add("Working Pressure");
    if (widget.certificate.testPressure?.isEmpty ?? true)
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
    if (!isC &&
        pickedImages["plate"] == null &&
        (widget.certificate.photoNumberPlate?.isEmpty ?? true))
      missing.add("Number Plate Photo");
    if (pickedImages["neck"] == null &&
        (widget.certificate.photoMarkingDetails?.isEmpty ?? true))
      missing.add("Cylinder Marking Photo");
    if (missing.isEmpty)
      _submitCertificateUpdate(context, prov);
    else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: FadeInUp(
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                            side: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
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

  Widget _buildSectionHeader(String t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            t,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05,
            ),
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
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            l1,
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            l2,
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w600,
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: theme.textTheme.bodyLarge?.color),
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
    final theme = Theme.of(context);
    return FormField<String>(
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: enabled
                    ? theme.inputDecorationTheme.fillColor
                    : theme.disabledColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: state.hasError ? Colors.red : theme.dividerColor,
                  width: state.hasError ? 1.5 : 1.0,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  dropdownColor: theme.cardColor,
                  hint: Text(
                    hint,
                    style: TextStyle(
                      fontSize: 14,
                      color: enabled
                          ? theme.textTheme.bodyLarge?.color
                          : theme.disabledColor,
                    ),
                  ),
                  items: enabled
                      ? items
                            .map(
                              (s) => DropdownMenuItem<String>(
                                value: s,
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                            )
                            .toList()
                      : null,
                  onChanged: enabled
                      ? (v) {
                          state.didChange(v);
                          onChanged(v);
                        }
                      : null,
                ),
              ),
            ),
            if (state.hasError)
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
  final bool showIcon;
  const _DatePickerField({
    this.displayDate,
    required this.onTap,
    this.validator,
    this.showIcon = true,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FormField<String>(
      validator: validator,
      initialValue: displayDate,
      builder: (state) {
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
                  color: theme.inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: state.hasError ? Colors.red : theme.dividerColor,
                    width: state.hasError ? 1.5 : 1.0,
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
                              ? theme.disabledColor
                              : theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    if (showIcon)
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                  ],
                ),
              ),
            ),
            if (state.hasError)
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
  final Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
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
    this.onFieldSubmitted,
    this.focusNode,
    this.validator,
    this.maxLength,
    this.enabled = true,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      enabled: enabled,
      style: TextStyle(fontSize: 14, color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: hint,
        counter: Container(),
        hintStyle: TextStyle(color: theme.disabledColor, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: theme.inputDecorationTheme.border,
        enabledBorder: theme.inputDecorationTheme.enabledBorder,
        focusedBorder: theme.inputDecorationTheme.focusedBorder,
        errorBorder: theme.inputDecorationTheme.errorBorder,
        focusedErrorBorder: theme.inputDecorationTheme.focusedErrorBorder,
        fillColor: theme.inputDecorationTheme.fillColor,
        filled: true,
      ),
    );
  }
}
