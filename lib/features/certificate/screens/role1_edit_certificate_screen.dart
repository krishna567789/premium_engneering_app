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

class Role1EditCertificateScreen extends StatefulWidget {
  final CertificateData certificate;
  const Role1EditCertificateScreen({super.key, required this.certificate});
  @override
  State<Role1EditCertificateScreen> createState() =>
      _Role1EditCertificateScreenState();
}

class _Role1EditCertificateScreenState
    extends State<Role1EditCertificateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController vehicleNumberController;
  late TextEditingController mobileNumberController;
  late TextEditingController manufacturingMonthController;
  late TextEditingController manufacturingYearController;
  late TextEditingController cascadeNoController;
  late TextEditingController amountController;
  late TextEditingController retailCustNameController;
  late TextEditingController remarksController;

  String? selectedVehicleType;
  int? selectedVehicleTypeId;
  String? selectedVehicleFormat;
  String? selectedDealer;
  dynamic selectedDealerId;
  String? collectionDate;
  String? lastTestingDate;
  Map<String, String?> pickedImages = {"plate": null};
  bool isVehicleWarning = false;
  bool isRemarkRequired = false;
  String? vehicleWarningMessage;
  bool isEarlyTestingDetected = false;
  bool _isPageLoading = true;
  late HomeProvider _homeProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeProvider = context.read<HomeProvider>();
  }

  @override
  void initState() {
    super.initState();
    final cert = widget.certificate;
    vehicleNumberController = TextEditingController(text: cert.vehicleNumber);
    mobileNumberController = TextEditingController(text: cert.mobile ?? "");
    if (cert.manufacturingDate != null &&
        cert.manufacturingDate!.contains("-")) {
      final parts = cert.manufacturingDate!.split("-");
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
      String m = parts[0].length == 4 ? parts[1] : parts[0];
      String y = parts[0].length == 4 ? parts[0] : parts[1];
      if (RegExp(r'^\d+$').hasMatch(m)) {
        int idx = int.parse(m) - 1;
        if (idx >= 0 && idx < 12) m = mNames[idx];
      }
      manufacturingMonthController = TextEditingController(text: m);
      manufacturingYearController = TextEditingController(text: y);
    } else {
      manufacturingMonthController = TextEditingController();
      manufacturingYearController = TextEditingController();
    }
    cascadeNoController = TextEditingController(
      text: cert.cascadeNumber ?? cert.cascadeNo,
    );
    final isRetailInitial =
        (cert.dealerId == 'rc01' ||
        cert.dealerId == 'rc001' ||
        cert.dealerId == 0 ||
        cert.dealerId == '0' ||
        cert.dealerName == "Retail Customer");
    selectedVehicleType = cert.vehicalType;
    selectedVehicleTypeId = int.tryParse(cert.vehicalType ?? "");
    selectedVehicleFormat = cert.vehicleFormat;
    selectedDealer = isRetailInitial ? "Retail Customer" : cert.dealerName;
    selectedDealerId = isRetailInitial ? 'rc01' : cert.dealerId;
    remarksController = TextEditingController(text: cert.remark ?? "");
    amountController = TextEditingController(
      text: cert.retailerAmount ?? cert.paymentAmount ?? "",
    );
    retailCustNameController = TextEditingController(
      text: isRetailInitial ? cert.dealerName : "",
    );
    if (cert.collectionDate != null &&
        cert.collectionDate!.contains("-") &&
        !cert.collectionDate!.startsWith("00")) {
      final parts = cert.collectionDate!.split("-");
      collectionDate = parts[0].length == 4
          ? "${parts[2]}-${parts[1]}-${parts[0]}"
          : cert.collectionDate;
    } else {
      collectionDate = null;
    }
    if (cert.lastTestDate != null &&
        cert.lastTestDate!.contains("-") &&
        !cert.lastTestDate!.startsWith("00")) {
      final parts = cert.lastTestDate!.split("-");
      lastTestingDate = parts[0].length == 4
          ? "${parts[2]}-${parts[1]}-${parts[0]}"
          : cert.lastTestDate;
    } else {
      lastTestingDate = null;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<HomeProvider>();
      provider.setIsRetailCustomer(isRetailInitial);
      final dId = isRetailInitial
          ? 'rc01'
          : (selectedDealerId?.toString() ?? '');
      provider.getVehicleFormat();
      provider.getDealerType();
      await provider.loadHomeData();
      String? currentProductId;
      if (provider.state.homeData?.data != null) {
        try {
          final product = provider.state.homeData!.data!.firstWhere(
            (p) =>
                p.fullname?.trim().toLowerCase() ==
                    cert.productType?.trim().toLowerCase() &&
                p.standard?.trim().toLowerCase() ==
                    cert.specification?.trim().toLowerCase(),
          );
          provider.setSelectedProduct(product);
          currentProductId = product.id?.toString();
        } catch (_) {
          if (provider.state.homeData!.data!.isNotEmpty) {
            final p = provider.state.homeData!.data!.first;
            provider.setSelectedProduct(p);
            currentProductId = p.id?.toString();
          }
        }
      }
      await provider.getVehicleType(dId, productId: currentProductId);
      if (selectedVehicleType != null &&
          provider.state.vehicleTypeData?.data != null) {
        try {
          final match = provider.state.vehicleTypeData!.data!.firstWhere(
            (e) =>
                e.vehicleName?.trim().toLowerCase() ==
                    selectedVehicleType?.trim().toLowerCase() ||
                e.id.toString() == selectedVehicleType?.trim(),
          );
          if (mounted) {
            setState(() {
              selectedVehicleTypeId = match.id;
              selectedVehicleType = match.vehicleName;
            });
          }
        } catch (e) {
          debugPrint("Role1Edit: Could not match vehicle type: $e");
        }
      }
      if (selectedVehicleTypeId != null && currentProductId != null) {
        provider.getProductAmountByDealer({
          'dealer_id': dId,
          'vehicle_id': selectedVehicleTypeId.toString(),
          'product_id': currentProductId,
        });
      }
      if (mounted) setState(() => _isPageLoading = false);
      _checkExpiryWarning();
    });
  }

  @override
  void dispose() {
    vehicleNumberController.dispose();
    mobileNumberController.dispose();
    manufacturingMonthController.dispose();
    manufacturingYearController.dispose();
    cascadeNoController.dispose();
    remarksController.dispose();
    retailCustNameController.dispose();
    _homeProvider.clearProductAmount();
    _homeProvider.clearDealerAmount();
    super.dispose();
  }

  Map<String, dynamic> _calculateExpiryInfo(HomeProvider provider) {
    final year = int.tryParse(manufacturingYearController.text);
    final monthText = manufacturingMonthController.text;
    if (year == null || monthText.isEmpty) {
      return {"date": "Auto Calculated", "isExpired": false};
    }
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
    int mIdx = mNames.indexOf(monthText);
    if (mIdx == -1) return {"date": "Auto Calculated", "isExpired": false};
    final lifeYears =
        provider.state.homeData?.data?.firstOrNull?.lifeOfCylinder ?? 20;
    int eYear = year + lifeYears;
    DateTime now = DateTime.now();
    bool expired =
        (eYear < now.year) || (eYear == now.year && (mIdx + 1) < now.month);
    return {"date": "${mNames[mIdx]} $eYear", "isExpired": expired};
  }

  Future<void> _checkVehicleNumber(String vehicleNo) async {
    if (vehicleNo.isEmpty) return;
    try {
      final authRepo = context.read<AuthRepository>();
      final userId = await authRepo.getUserId();
      final adminId = await authRepo.getAdminId();
      final provider = context.read<HomeProvider>();
      final iCount =
          provider.state.homeData?.data?.firstOrNull?.intervalTesting ?? 3;
      final now = DateTime.now();
      final cDateStr = (collectionDate != null && collectionDate!.isNotEmpty)
          ? collectionDate!
          : '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      await provider.checkVehicleNumber({
        'vehicleno': vehicleNo,
        'userid': userId ?? '',
        'admin_id': adminId ?? '',
        'intervel_count': iCount.toString(),
        'collection_date': cDateStr,
        'vehicle_type_id': selectedVehicleTypeId?.toString() ?? '',
        'product_id': provider.state.selectedProduct?.id?.toString() ?? '',
      });
      final resp = provider.state.vehicleCheckData;
      if (resp != null) {
        final status = resp['status'];
        final message = resp['message']?.toString() ?? '';
        final isW =
            status == true ||
            status == 'true' ||
            status == 1 ||
            status.toString().toLowerCase() == 'success';
        if (isW && message.isNotEmpty) {
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
              final provider = context.read<HomeProvider>();
              final info = _calculateExpiryInfo(provider);
              _removeRemark("Vehicle Alert");
            });
          }
        }
      }
    } catch (e) {
      debugPrint('🚗 Vehicle check error: $e');
    }
  }

  void _showVehicleWarningDialog(String message) {
    TextEditingController popupRemarkCtrl = TextEditingController(
      text: message,
    );
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: popupRemarkCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Remark",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                isRemarkRequired = true;
                _addOrUpdateRemark("Vehicle Alert", popupRemarkCtrl.text);
              });
            },
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
    if (collectionDate == null ||
        manufacturingMonthController.text.isEmpty ||
        manufacturingYearController.text.isEmpty) {
      return;
    }
    try {
      final testParts = collectionDate!.split("-");
      if (testParts.length != 3) return;
      final testDT = DateTime(
        int.parse(testParts[2]),
        int.parse(testParts[1]),
        int.parse(testParts[0]),
      );
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
      if (mIdx == -1) return;
      int mYear = int.parse(manufacturingYearController.text);
      final provider = context.read<HomeProvider>();
      final iTesting =
          provider.state.homeData?.data?.firstOrNull?.intervalTesting ?? 3;
      if (testDT.isBefore(DateTime(mYear + iTesting, mIdx + 1, 1))) {
        setState(() => isEarlyTestingDetected = true);
        _showEarlyTestingDialog();
      } else {
        setState(() {
          isEarlyTestingDetected = false;
          final info = _calculateExpiryInfo(provider);
          _removeRemark("Testing Alert");
        });
      }
    } catch (e) {
      debugPrint("Error checking interval: $e");
    }
  }

  void _showEarlyTestingDialog() {
    const String defaultMessage =
        "You've come in for testing earlier than the scheduled interval. If you proceed, you must provide a reason in the Remarks field below.";
    TextEditingController popupRemarkCtrl = TextEditingController(
      text: defaultMessage,
    );
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: popupRemarkCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Remark",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isRemarkRequired = true;
                _addOrUpdateRemark("Testing Alert", popupRemarkCtrl.text);
              });
            },
            child: const Text(
              "OK",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _checkExpiryWarning() {
    final provider = context.read<HomeProvider>();
    final info = _calculateExpiryInfo(provider);
    if (info["isExpired"] as bool) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showExpiredWarningDialog(),
      );
    } else { if (mounted) { setState(() { _removeRemark("Cylinder Expired"); }); } }
  }

  void _addOrUpdateRemark(String title, String message) {
    if (message.trim().isEmpty) return;
    String cleanMessage = message.replaceAll('\n', ' ').trim();
    String newRemark = "$title: $cleanMessage";
    if (remarksController.text.trim().isEmpty) {
      remarksController.text = newRemark;
    } else {
      final lines = remarksController.text.split('\n');
      bool found = false;
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].startsWith("$title:")) {
          lines[i] = newRemark;
          found = true;
          break;
        }
      }
      if (!found) {
        lines.add(newRemark);
      }
      remarksController.text = lines.join('\n');
    }
  }

  void _removeRemark(String title) {
    if (remarksController.text.trim().isNotEmpty) {
      final lines = remarksController.text.split('\n');
      final newLines = lines.where((line) => !line.startsWith("$title:")).toList();
      remarksController.text = newLines.join('\n');
    }
    if (remarksController.text.trim().isEmpty) {
      setState(() {
        isRemarkRequired = false;
      });
    }
  }


  void _showExpiredWarningDialog() {
    const String defaultMessage =
        "your cylinder expire you can not perform test";
    TextEditingController popupRemarkCtrl = TextEditingController(
      text: defaultMessage,
    );
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: popupRemarkCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Remark",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                isRemarkRequired = true;
                _addOrUpdateRemark("Cylinder Expired", popupRemarkCtrl.text);
              });
            },
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

  Future<void> _pickAndCompressImage(String tag) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
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
    if (source == null) return;
    final img = await picker.pickImage(source: source);
    if (img != null) setState(() => pickedImages[tag] = img.path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String? formatDDate(String? s) {
      if (s == null || s.isEmpty || !s.contains("-")) return s;
      final p = s.split("-");
      return (p.length == 3 && p[0].length == 4)
          ? "${p[2]}-${p[1]}-${p[0]}"
          : s;
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
                    _buildActionCard(
                      child: Column(
                        children: [
                          _RowLabels(
                            l1: "Vehicle Type${selectedVehicleType != null && selectedVehicleType!.isNotEmpty ? " : $selectedVehicleType" : ""}",
                            l2: "Collection Date",
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Consumer<HomeProvider>(
                                  builder: (context, provider, _) {
                                    final vTypes =
                                        provider.state.vehicleTypeData?.data ??
                                        [];
                                    final types = vTypes
                                        .map((e) => e.vehicleName ?? "")
                                        .toList();
                                    String dVal =
                                        (selectedVehicleType == null ||
                                            selectedVehicleType!.isEmpty)
                                        ? "Select Type"
                                        : selectedVehicleType!;
                                    try {
                                      final match = vTypes.firstWhere(
                                        (e) =>
                                            e.id.toString() == dVal ||
                                            e.vehicleName
                                                    ?.trim()
                                                    .toLowerCase() ==
                                                dVal.trim().toLowerCase(),
                                      );
                                      dVal = match.vehicleName ?? dVal;
                                    } catch (_) {}
                                    return _DropDownField(
                                      hint: dVal,
                                      items: types,
                                      validator: (v) =>
                                          (selectedVehicleType == null)
                                          ? "Required"
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
                                          if (sel.id != null && dId != null) {
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
                                          }
                                        } catch (_) {}
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _DatePickerField(
                                  displayDate: formatDDate(collectionDate),
                                  validator: (v) => (collectionDate == null)
                                      ? "Required"
                                      : null,
                                  onTap: () async {
                                    final d = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );
                                    if (d != null) {
                                      setState(
                                        () => collectionDate =
                                            "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}",
                                      );
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
                                  provider.state.productAmount != null) {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: theme.inputDecorationTheme.fillColor,
                                  ),
                                  child: Column(
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
                                          null)
                                        Text(
                                          "Total Dues Pending: ₹ ${provider.state.totalDuesPending}",
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
                          Consumer<HomeProvider>(
                            builder: (context, provider, _) {
                              final vTypes =
                                  provider.state.vehicleTypeData?.data ?? [];
                              bool isCasc =
                                  selectedVehicleType?.toLowerCase().contains(
                                    'cascade',
                                  ) ??
                                  false;
                              if (!isCasc) {
                                try {
                                  final m = vTypes.firstWhere(
                                    (e) =>
                                        e.id.toString() ==
                                            selectedVehicleType ||
                                        e.vehicleName == selectedVehicleType,
                                  );
                                  if (m.vehicleName?.toLowerCase().contains(
                                        'cascade',
                                      ) ??
                                      false) {
                                    isCasc = true;
                                  }
                                } catch (_) {}
                              }
                              final productName =
                                  provider.state.selectedProduct?.fullname
                                      ?.toLowerCase() ??
                                  '';
                              bool isCNG =
                                  productName.contains('cng') ||
                                  (productName.contains('compress') &&
                                      productName.contains('natural') &&
                                      productName.contains('gas'));
                              bool isOxygen = productName.contains('oxygen');

                              return Column(
                                children: [
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
                                                    ? "Required"
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Expanded(child: SizedBox()),
                                          ],
                                        ),
                                      ],
                                    ),
                                  if ((isCNG || isOxygen) && !isCasc)
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
                                                  final fms =
                                                      p
                                                          .state
                                                          .vehicleFormatData
                                                          ?.data
                                                          ?.map(
                                                            (e) =>
                                                                e.vFormat ?? "",
                                                          )
                                                          .toList() ??
                                                      [];
                                                  return _DropDownField(
                                                    hint:
                                                        selectedVehicleFormat ??
                                                        "Format",
                                                    items: fms,
                                                    validator: (v) =>
                                                        (selectedVehicleFormat ==
                                                            null)
                                                        ? "Required"
                                                        : null,
                                                    onChanged: (v) => setState(
                                                      () =>
                                                          selectedVehicleFormat =
                                                              v,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: _ManualField(
                                                hint: "Number",
                                                controller:
                                                    vehicleNumberController,
                                                validator: (v) =>
                                                    (v == null || v.isEmpty)
                                                    ? "Required"
                                                    : null,
                                                textCapitalization:
                                                    TextCapitalization
                                                        .characters,
                                                keyboardType:
                                                    (selectedVehicleFormat
                                                            ?.toUpperCase()
                                                            .contains('X') ??
                                                        true)
                                                    ? TextInputType
                                                          .visiblePassword
                                                    : TextInputType.number,
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                    (selectedVehicleFormat
                                                                ?.isNotEmpty ==
                                                            true)
                                                        ? selectedVehicleFormat!
                                                              .length
                                                        : 13,
                                                  ),
                                                  VehicleNumberSmartFormatter(
                                                    selectedVehicleFormat,
                                                  ),
                                                ],
                                                onChanged: (v) {
                                                  if (v.length >= 6) {
                                                    _checkVehicleNumber(v);
                                                  }
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
                          Consumer<HomeProvider>(
                            builder: (context, provider, _) {
                              final dList =
                                  provider.state.dealerTypeData?.data ?? [];
                              final dealers = [
                                "Retail Customer",
                                ...dList.map((e) => e.fullname ?? ""),
                              ];
                              final isRet = provider.state.isRetailCustomer;
                              String dVal =
                                  (selectedDealer == null ||
                                      selectedDealer!.isEmpty)
                                  ? "Select Dealer"
                                  : selectedDealer!;
                              if (selectedDealerId != null) {
                                try {
                                  final m = dList.firstWhere(
                                    (e) =>
                                        e.id?.toString() ==
                                        selectedDealerId?.toString(),
                                  );
                                  dVal = m.fullname ?? dVal;
                                } catch (_) {}
                              }
                              return Column(
                                children: [
                                  const SizedBox(height: 15),
                                  _RowLabels(
                                    l1: "Select Dealer Name",
                                    l2: isRet
                                        ? "Retail Customer Name"
                                        : "Enter Mobile No.",
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _DropDownField(
                                          enabled: !isRet,
                                          hint: dVal,
                                          items: dealers,
                                          validator: (v) =>
                                              (selectedDealer == null)
                                              ? "Required"
                                              : null,
                                          onChanged: (val) {
                                            if (val == null ||
                                                val == "Retail Customer") {
                                              provider.setIsRetailCustomer(
                                                true,
                                              );
                                              setState(() {
                                                selectedDealer = val;
                                                selectedDealerId = 'rc01';
                                                mobileNumberController.clear();
                                              });
                                              provider.clearDealerAmount();
                                              provider.clearProductAmount();
                                              provider.getVehicleType(
                                                'rc01',
                                                productId: provider
                                                    .state
                                                    .selectedProduct
                                                    ?.id
                                                    ?.toString(),
                                              );
                                              return;
                                            }
                                            try {
                                              final sel = dList.firstWhere(
                                                (e) => e.fullname == val,
                                              );
                                              final ret = val
                                                  .toLowerCase()
                                                  .contains('retail');
                                              provider.setIsRetailCustomer(ret);
                                              setState(() {
                                                selectedDealer = val;
                                                selectedDealerId = sel.id;
                                                if (!ret) {
                                                  mobileNumberController.text =
                                                      sel.mobileNo ?? '';
                                                }
                                              });
                                              if (ret) {
                                                provider.clearDealerAmount();
                                                provider.clearProductAmount();
                                                provider.getVehicleType(
                                                  'rc01',
                                                  productId: provider
                                                      .state
                                                      .selectedProduct
                                                      ?.id
                                                      ?.toString(),
                                                );
                                              } else if (sel.id != null) {
                                                provider.getVehicleType(
                                                  sel.id.toString(),
                                                  productId: provider
                                                      .state
                                                      .selectedProduct
                                                      ?.id
                                                      ?.toString(),
                                                );
                                                provider
                                                    .getProductAmountByDealer({
                                                      'dealer_id': sel.id
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
                                      Expanded(
                                        child: _ManualField(
                                          hint: isRet
                                              ? "Enter Customer Name"
                                              : "Mobile",
                                          controller: isRet
                                              ? retailCustNameController
                                              : mobileNumberController,
                                          keyboardType: isRet
                                              ? TextInputType.text
                                              : TextInputType.phone,
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return "Required";
                                            }
                                            if (!isRet && v.length != 10) {
                                              return "10 digits required";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isRet)
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
                                                controller: amountController,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                validator: (v) =>
                                                    (isRet &&
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
                                                  if (v == null || v.isEmpty) {
                                                    return "Required";
                                                  }
                                                  if (v.length != 10) {
                                                    return "Must be 10 digits";
                                                  }
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
                        ],
                      ),
                    ),
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
                          const _RowLabels(l1: "Manufacturing Date", l2: ""),
                          const SizedBox(height: 8),
                          Row(
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
                                      ? "Required"
                                      : null,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
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
                                        return AlertDialog(
                                          title: const Text("Select Month"),
                                          content: SizedBox(
                                            width: 300,
                                            height: 300,
                                            child: ListView.builder(
                                              itemCount: 12,
                                              itemBuilder: (context, index) {
                                                final mName = mNames[index];
                                                int? sY = int.tryParse(
                                                  manufacturingYearController
                                                      .text,
                                                );
                                                bool isF =
                                                    (sY ==
                                                        DateTime.now().year &&
                                                    (index + 1) >
                                                        DateTime.now().month);
                                                return ListTile(
                                                  title: Text(
                                                    mName,
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
                                                          setState(
                                                            () =>
                                                                manufacturingMonthController
                                                                        .text =
                                                                    mName,
                                                          );
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          WidgetsBinding
                                                              .instance
                                                              .addPostFrameCallback((
                                                                _,
                                                              ) {
                                                                _checkIntervalWarning();
                                                                _checkExpiryWarning();
                                                              });
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
                                      ? "Required"
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
                                              onChanged: (dt) {
                                                setState(() {
                                                  manufacturingYearController
                                                      .text = dt.year
                                                      .toString();
                                                  if (dt.year ==
                                                      DateTime.now().year) {
                                                    const List<String> mNames =
                                                        [
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
                                                    int mIdx = mNames.indexOf(
                                                      manufacturingMonthController
                                                          .text,
                                                    );
                                                    if (mIdx + 1 >
                                                        DateTime.now().month) {
                                                      manufacturingMonthController
                                                              .text =
                                                          "";
                                                    }
                                                  }
                                                });
                                                Navigator.pop(context);
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                      _checkIntervalWarning();
                                                      _checkExpiryWarning();
                                                    });
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
                        ],
                      ),
                    ),
                    Consumer<HomeProvider>(
                      builder: (context, provider, _) {
                        final info = _calculateExpiryInfo(provider);
                        final isE = info["isExpired"] as bool;
                        return Column(
                          children: [
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Text(
                                  "Expiry Date",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.textTheme.bodyLarge?.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (isE)
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
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _ValueBox(
                                    text: info["date"] as String,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(child: SizedBox()),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    if (isRemarkRequired || remarksController.text.trim().isNotEmpty) ...[
                      _buildSectionHeader("Remarks"),
                      _buildActionCard(
                        child: _ManualField(
                          hint: "Remarks",
                          controller: remarksController,
                          maxLines: 3,
                          onChanged: (v) {},
                          validator: (v) {
                            if (isRemarkRequired && (v == null || v.trim().isEmpty)) {
                              return "Remark is required.";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    _buildSectionHeader("Photo Uploads"),
                    _buildActionCard(
                      child: DashedUploadArea(
                        title: "Update Photo of Number Plate",
                        onPick: () => _pickAndCompressImage("plate"),
                        imagePath: pickedImages["plate"],
                        networkImageUrl:
                            (widget.certificate.photoNumberPlate?.isNotEmpty ??
                                false)
                            ? "https://pe.microcmd.com/API/uploads/${widget.certificate.photoNumberPlate}"
                            : null,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Consumer<HomeProvider>(
                      builder: (context, provider, _) {
                        return CustomButton(
                          text: "Update Certificate",
                          isLoading:
                              provider.state.certificateStatus ==
                              HomeStatus.loading,
                          onPressed: () async {
                            final Map<String, dynamic> data = {
                              'vehicle_number': vehicleNumberController.text,
                              'license_name': 'PREMIUM HYDRO ENGINEERING',
                              'approval_no': 'AG/HQ/GJ/GCT/1G49051',
                              'vehicle_type':
                                  selectedVehicleTypeId?.toString() ??
                                  selectedVehicleType ??
                                  '',
                              'collection_date': collectionDate ?? '',
                              'vehicle_format': selectedVehicleFormat ?? '',
                              'cascade_no': cascadeNoController.text,
                              'product_type': 'Compress Natural Gas',
                              'specification': 'IS 15490',
                              'last_test_date': lastTestingDate ?? '',
                              'manufacturing_date': () {
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
                                String mS = manufacturingMonthController.text
                                    .trim();
                                String mm = '01';
                                if (RegExp(r'^\d+$').hasMatch(mS)) {
                                  mm = mS.padLeft(2, '0');
                                } else {
                                  int i = mNames.indexOf(mS);
                                  if (i != -1) {
                                    mm = (i + 1).toString().padLeft(2, '0');
                                  }
                                }
                                return '$mm-${manufacturingYearController.text}';
                              }(),
                              'dealer_name': provider.state.isRetailCustomer
                                  ? 'rc01'
                                  : (selectedDealerId?.toString() ?? ''),
                              'mobile_no': mobileNumberController.text,
                              'remarks': remarksController.text,
                              if (provider.state.isRetailCustomer) ...{
                                'retail_amount': amountController.text,
                                'retail_cust_name':
                                    retailCustNameController.text,
                              } else
                                'amount':
                                    provider.state.productAmount ??
                                    widget.certificate.paymentAmount ??
                                    '',
                              'Payment_amount': provider.state.productAmount ?? widget.certificate.paymentAmount ?? '',
                              'retail_customer': provider.state.isRetailCustomer
                                  ? '001'
                                  : '',
                              'c_id': widget.certificate.id.toString(),
                              'photo_path': pickedImages['plate'],
                            };
                            bool success = await provider
                                .updateRole1Certificate(data, context);
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
                                              color: Colors.green.withValues(
                                                alpha: 0.1,
                                              ),
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
                                              color: theme
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "Certificate updated successfully.",
                                            style: TextStyle(
                                              color: theme
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color,
                                              fontSize: 15,
                                            ),
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
                                                backgroundColor:
                                                    theme.colorScheme.primary,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 15,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
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
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
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
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
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
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.2
                  : 0.05,
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
                    : theme.disabledColor.withValues(alpha: 0.1),
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
                padding: const EdgeInsets.only(top: 5, left: 5),
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
                padding: const EdgeInsets.only(top: 5, left: 5),
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
    this.enabled = true,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      style: TextStyle(fontSize: 14, color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: hint,
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
