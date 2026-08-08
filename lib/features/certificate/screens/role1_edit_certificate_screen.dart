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
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../core/theme.dart';
import '../../../widgets/custom_widgets.dart';
import '../../home/provider/home_provider.dart';
import '../../home/model/role1_certificate_list_model.dart';
import '../../auth/data/auth_repository.dart';

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

  String? selectedVehicleType;
  int? selectedVehicleTypeId;
  String? selectedVehicleFormat;
  String? selectedDealer;
  dynamic selectedDealerId;
  String? collectionDate;
  String? lastTestingDate;

  Map<String, String?> pickedImages = {"plate": null};

  // vehicle check + interval state
  bool isVehicleWarning = false;
  bool isRemarkRequired = false;
  String? vehicleWarningMessage;
  bool isEarlyTestingDetected = false;
  bool _hasShownExpiryWarning = false;
  late TextEditingController remarksController;

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

    // Split manufacturing date "2020-04" or "04-2020"
    if (cert.manufacturingDate != null &&
        cert.manufacturingDate!.contains("-")) {
      final parts = cert.manufacturingDate!.split("-");
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

      String m = "";
      String y = "";

      if (parts[0].length == 4) {
        y = parts[0];
        m = parts[1];
      } else {
        m = parts[0];
        y = parts[1];
      }

      // Convert month number to name if it's a number
      if (RegExp(r'^\d+$').hasMatch(m)) {
        int idx = int.parse(m) - 1;
        if (idx >= 0 && idx < 12) {
          m = monthNames[idx];
        }
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

    final isRetailInitial = (cert.dealerId == 'rc01' ||
        cert.dealerId == 'rc001' ||
        cert.dealerId == 0 ||
        cert.dealerId == '0' ||
        cert.dealerName == "Retail Customer");

    selectedVehicleType = cert.vehicalType;
    selectedVehicleFormat = cert.vehicleFormat;
    selectedDealer = isRetailInitial ? "Retail Customer" : cert.dealerName;
    selectedDealerId = isRetailInitial ? 'rc01' : cert.dealerId;
    remarksController = TextEditingController();
    amountController = TextEditingController(text: cert.retailerAmount ?? cert.paymentAmount ?? "");
    retailCustNameController = TextEditingController(
      text: isRetailInitial ? cert.dealerName : "",
    );

    if (cert.collectionDate != null &&
        cert.collectionDate!.contains("-") &&
        !cert.collectionDate!.startsWith("00")) {
      final parts = cert.collectionDate!.split("-");
      if (parts[0].length == 4) {
        collectionDate = "${parts[2]}-${parts[1]}-${parts[0]}";
      } else {
        collectionDate = cert.collectionDate;
      }
    } else {
      collectionDate = null;
    }

    if (cert.lastTestDate != null &&
        cert.lastTestDate!.contains("-") &&
        !cert.lastTestDate!.startsWith("00")) {
      final parts = cert.lastTestDate!.split("-");
      if (parts[0].length == 4) {
        lastTestingDate = "${parts[2]}-${parts[1]}-${parts[0]}";
      } else {
        lastTestingDate = cert.lastTestDate;
      }
    } else {
      lastTestingDate = null;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<HomeProvider>();

      // Sync isRetailCustomer state from existing certificate data
      final isRetail =
          (selectedDealerId == 'rc01' ||
          selectedDealerId == 'rc01' ||
          selectedDealerId == 0 ||
          selectedDealerId == '0' ||
          selectedDealer == "Retail Customer");
      provider.setIsRetailCustomer(isRetail);

      final dId = isRetail ? 'rc01' : (selectedDealerId?.toString() ?? '');
      provider.getVehicleFormat();
      provider.getDealerType();
      await provider.loadHomeData();

      // Set selected product for price fetching BEFORE calling getVehicleType
      String? currentProductId;
      if (provider.state.homeData?.data != null) {
        try {
          final product = provider.state.homeData!.data!.firstWhere(
            (p) =>
                p.fullname == cert.productType &&
                p.standard == cert.specification,
          );
          provider.setSelectedProduct(product);
          currentProductId = product.id?.toString();
        } catch (_) {
          if (provider.state.homeData!.data!.isNotEmpty) {
            final firstProduct = provider.state.homeData!.data!.first;
            provider.setSelectedProduct(firstProduct);
            currentProductId = firstProduct.id?.toString();
          }
        }
      }

      await provider.getVehicleType(dId, productId: currentProductId);

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

      // Initial price fetch if everything is ready
      if (selectedVehicleTypeId != null && currentProductId != null) {
        provider.getProductAmountByDealer({
          'dealer_id': dId,
          'vehicle_id': selectedVehicleTypeId.toString(),
          'product_id': currentProductId,
        });
      }

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
    int monthIndex = monthNames.indexOf(monthText);
    if (monthIndex == -1) {
      return {"date": "Auto Calculated", "isExpired": false};
    }

    final lifeYears =
        provider.state.homeData?.data?.firstOrNull?.lifeOfCylinder ?? 20;
    int expiryYearValue = year + lifeYears;
    int monthNum = monthIndex + 1;

    DateTime now = DateTime.now();
    bool expired = false;
    if (expiryYearValue < now.year) {
      expired = true;
    } else if (expiryYearValue == now.year) {
      if (monthNum < now.month) {
        expired = true;
      }
    }

    return {
      "date": "${monthNames[monthIndex]} $expiryYearValue",
      "isExpired": expired,
    };
  }

  Future<void> _checkVehicleNumber(String vehicleNo) async {
    debugPrint('🚗 _checkVehicleNumber called: $vehicleNo');
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
      final collectionDateStr =
          (collectionDate != null && collectionDate!.isNotEmpty)
          ? collectionDate!
          : fallbackDate;

      await provider.checkVehicleNumber({
        'vehicleno': vehicleNo,
        'userid': userId ?? '',
        'admin_id': adminId ?? '',
        'intervel_count': intervalCount.toString(),
        'collection_date': collectionDateStr,
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
      debugPrint('🚗 Vehicle check error: $e');
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
    if (collectionDate == null ||
        manufacturingMonthController.text.isEmpty ||
        manufacturingYearController.text.isEmpty)
      return;
    try {
      final testParts = collectionDate!.split("-");
      if (testParts.length != 3) return;
      final testDateTime = DateTime(
        int.parse(testParts[2]),
        int.parse(testParts[1]),
        int.parse(testParts[0]),
      );
      const List<String> monthNames = [
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
      final provider = context.read<HomeProvider>();
      final intervalTesting =
          provider.state.homeData?.data?.firstOrNull?.intervalTesting ?? 3;
      final thresholdDate = DateTime(
        mfgYear + intervalTesting,
        monthIndex + 1,
        1,
      );
      if (testDateTime.isBefore(thresholdDate)) {
        setState(() => isEarlyTestingDetected = true);
        _showEarlyTestingDialog();
      } else {
        setState(() => isEarlyTestingDetected = false);
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
          "You've come in for testing earlier than the scheduled interval. If you proceed, you must provide a reason in the Remarks field below.",
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

  void _checkExpiryWarning() {
    final provider = context.read<HomeProvider>();
    final expiryInfo = _calculateExpiryInfo(provider);
    final isExpired = expiryInfo["isExpired"] as bool;

    if (isExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showExpiredWarningDialog();
      });
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
    if (image == null) return;

    debugPrint("DEBUG: Picked Image Path ($tag): ${image.path}");
    setState(() {
      pickedImages[tag] = image.path;
    });
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
          "Update Certificate (Role 1)",
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
              _buildActionCard(
                child: Column(
                  children: [
                    const _RowLabels(l1: "Vehicle Type", l2: "Collection Date"),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Consumer<HomeProvider>(
                            builder: (context, provider, _) {
                              final vehicleTypes =
                                  provider.state.vehicleTypeData?.data ?? [];
                              final types = vehicleTypes
                                  .map((e) => e.vehicleName ?? "")
                                  .toList();

                              String displayValue =
                                  selectedVehicleType ?? "Select Type";
                              try {
                                final match = vehicleTypes.firstWhere(
                                  (e) =>
                                      e.id.toString() == displayValue ||
                                      e.vehicleName == displayValue,
                                );
                                displayValue =
                                    match.vehicleName ?? displayValue;
                              } catch (_) {}

                              return _DropDownField(
                                hint: displayValue,
                                items: types,
                                validator: (v) => (selectedVehicleType == null)
                                    ? "Required"
                                    : null,
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
                                      "Role1Edit: Vehicle changed. dId: $dId, vId: ${selected.id}, pId: ${provider.state.selectedProduct?.id}",
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
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DatePickerField(
                            displayDate: formatDisplayDate(collectionDate),
                            validator: (v) =>
                                (collectionDate == null) ? "Required" : null,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() {
                                  collectionDate =
                                      "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
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
                            provider.state.productAmount != null) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[200],
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
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
                                  if (provider.state.totalDuesPending != null)
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
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 15),
                    Consumer<HomeProvider>(
                      builder: (context, provider, _) {
                        final vehicleTypes =
                            provider.state.vehicleTypeData?.data ?? [];
                        bool isCascade = false;
                        if (selectedVehicleType != null) {
                          if (selectedVehicleType!.toLowerCase().contains(
                            'cascade',
                          )) {
                            isCascade = true;
                          } else {
                            try {
                              final match = vehicleTypes.firstWhere(
                                (e) =>
                                    e.id.toString() == selectedVehicleType ||
                                    e.vehicleName == selectedVehicleType,
                              );
                              if (match.vehicleName?.toLowerCase().contains(
                                    'cascade',
                                  ) ??
                                  false) {
                                isCascade = true;
                              }
                            } catch (_) {}
                          }
                        }

                        bool isCNG = false;
                        final productName = provider.state.selectedProduct?.fullname?.toLowerCase() ?? '';
                        if (productName.contains('cng') || (productName.contains('compress') && productName.contains('natural') && productName.contains('gas'))) {
                          isCNG = true;
                        }

                        return Column(
                          children: [
                            if (isCascade) ...[
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
                                      validator: (val) {
                                        if (val == null || val.isEmpty) {
                                          return "Required";
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
                                            provider
                                                .state
                                                .vehicleFormatData
                                                ?.data
                                                ?.map((e) => e.vFormat ?? "")
                                                .toList() ??
                                            [];
                                        return _DropDownField(
                                          hint:
                                              selectedVehicleFormat ?? "Format",
                                          items: formats,
                                          validator: (v) =>
                                              (selectedVehicleFormat == null)
                                              ? "Required"
                                              : null,
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
                                      validator: (v) => (v == null || v.isEmpty)
                                          ? "Required"
                                          : null,
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
                                        debugPrint(
                                          '🚗 onChanged fired: "$val" (len=${val.length})',
                                        );
                                        if (val.length >= 6) {
                                          _checkVehicleNumber(val);
                                        }
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
                    Consumer<HomeProvider>(
                      builder: (context, provider, _) {
                        final dealerList =
                            provider.state.dealerTypeData?.data ?? [];
                        final dealers = [
                          "Retail Customer",
                          ...dealerList.map((e) => e.fullname ?? ""),
                        ];
                        final isRetail = provider.state.isRetailCustomer;

                        String displayValue = selectedDealer ?? "Select Dealer";
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
                            const SizedBox(height: 15),
                            _RowLabels(
                              l1: "Select Dealer Name",
                              l2: isRetail ? "Retail Customer Name" : "Enter Mobile No.",
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
                                    validator: (v) => (selectedDealer == null)
                                        ? "Required"
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
                                        final selected = dealerList.firstWhere(
                                          (e) => e.fullname == val,
                                        );
                                        final retail =
                                            val?.toLowerCase().contains(
                                              'retail',
                                            ) ??
                                            false;
                                        provider.setIsRetailCustomer(retail);

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
                                          provider.getProductAmountByDealer({
                                            'dealer_id': selected.id.toString(),
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
                                        FilteringTextInputFormatter.digitsOnly,
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
                                        FilteringTextInputFormatter.digitsOnly,
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
                            text: widget.certificate.specification ?? "N/A",
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
                                      ? "Required"
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

                                                int?
                                                selectedYear = int.tryParse(
                                                  manufacturingYearController
                                                      .text,
                                                );
                                                bool isCurrentYear =
                                                    selectedYear == null ||
                                                    selectedYear ==
                                                        DateTime.now().year;
                                                bool isFutureMonth =
                                                    isCurrentYear &&
                                                    monthNumber >
                                                        DateTime.now().month;

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
                                                          });
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
                        ),
                      ],
                    ),
                    Consumer<HomeProvider>(
                      builder: (context, provider, _) {
                        final expiryInfo = _calculateExpiryInfo(provider);
                        final isExpired = expiryInfo["isExpired"] as bool;
                        final expiryDate = expiryInfo["date"] as String;

                        return Column(
                          children: [
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                const Text(
                                  "Expiry Date",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (isExpired) ...[
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
                                Expanded(child: _ValueBox(text: expiryDate)),
                                const SizedBox(width: 10),
                                const Expanded(child: SizedBox()),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

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
                  ],
                ),
              ),

              /// Remarks - always visible in edit screen
              _buildSectionHeader("Remarks"),
              _buildActionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isVehicleWarning)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          vehicleWarningMessage ?? "Vehicle alert detected.",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
                        if ((isVehicleWarning || isEarlyTestingDetected) &&
                            (v == null || v.trim().isEmpty)) {
                          return "Remark is required.";
                        }
                        return null;
                      },
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Consumer<HomeProvider>(
                builder: (context, provider, _) {
                  return CustomButton(
                    text: "Update Certificate",
                    isLoading:
                        provider.state.certificateStatus == HomeStatus.loading,
                    onPressed: () async {
                      // if (!_formKey.currentState!.validate()) {
                      //   CustomToast.error(
                      //     context,
                      //     "Please fill all required fields",
                      //     top: true,
                      //   );
                      //   return;
                      // }
                      final authRepo = context.read<AuthRepository>();
                      final userId = await authRepo.getUserId();

                      final Map<String, dynamic> data = {
                        'vehicle_number': vehicleNumberController.text,
                        'license_name': 'PREMIUM HYDRO ENGINEERING',
                        'approval_no': 'AG/HQ/GJ/GCT/1G49051',
                        'vehical_type':
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
                          String monthStr = manufacturingMonthController.text
                              .trim();
                          String mm = '01';
                          if (RegExp(r'^\d+$').hasMatch(monthStr)) {
                            mm = monthStr.padLeft(2, '0');
                          } else {
                            int mIdx = monthNames.indexOf(monthStr);
                            if (mIdx != -1)
                              mm = (mIdx + 1).toString().padLeft(2, '0');
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
                          'retail_cust_name': retailCustNameController.text,
                        } else
                          'amount':
                              provider.state.productAmount ??
                              widget.certificate.paymentAmount ??
                              '',
                        'retail_customer': provider.state.isRetailCustomer
                            ? '001'
                            : '',
                        'c_id': widget.certificate.id.toString(),
                        'photo_path': pickedImages['plate'],
                      };

                      debugPrint(
                        "DEBUG: Sending Role 1 Certificate Data: $data",
                      );
                      debugPrint(
                        "DEBUG: Plate Image Path: ${pickedImages['plate']}",
                      );

                      bool success = await provider.updateRole1Certificate(
                        data,
                        context,
                      );
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
                                            backgroundColor: AppColors.primary,
                                            padding: const EdgeInsets.symmetric(
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
                            );
                          },
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
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            l2,
            style: const TextStyle(
              fontSize: 12,
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
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: enabled ? Colors.white : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: state.hasError
                      ? Colors.red
                      : Colors.grey.withOpacity(0.3),
                  width: state.hasError ? 1.5 : 1.0,
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
                      ? items.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList()
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
    return FormField<String>(
      validator: validator,
      initialValue: displayDate,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                onTap();
                // We'll need to manually trigger state change if displayDate changes externally
                // But for simplicity in these screens, usually state.didChange is called after pick
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: state.hasError
                        ? Colors.red
                        : Colors.grey.withOpacity(0.3),
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
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.primary,
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
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
