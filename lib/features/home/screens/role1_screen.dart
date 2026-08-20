import 'package:flutter/material.dart';
import 'package:premium_engneering_app/core/theme.dart';
import 'package:premium_engneering_app/features/home/screens/licence_detail.dart';
import 'role1_certificate_list_screen.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:premium_engneering_app/core/theme_provider.dart';
import '../../../widgets/custom_widgets.dart';
import '../provider/home_provider.dart';
import '../provider/home_state.dart';
import '../widgets/home_components.dart';
import 'package:flutter/services.dart';
import '../../auth/data/auth_repository.dart';

class VehicleNumberSmartFormatter extends TextInputFormatter {
  final String? format;
  VehicleNumberSmartFormatter(this.format);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final fmt = format;
    if (fmt == null || fmt.trim().isEmpty) {
      final up = newValue.text.toUpperCase();
      return TextEditingValue(
        text: up,
        selection: TextSelection.collapsed(offset: up.length),
      );
    }
    final raw = newValue.text.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );
    final slots = fmt.split('').where((c) => c != '-').map((c) {
      if (c == '0') return 'd';
      if (c.toUpperCase() == 'X') return 'l';
      return 'a';
    }).toList();
    String filtered = '';
    int si = 0;
    for (final ch in raw.split('')) {
      if (si >= slots.length) break;
      final slot = slots[si];
      if (slot == 'd' && RegExp(r'\d').hasMatch(ch)) {
        filtered += ch;
        si++;
      } else if (slot == 'l' && RegExp(r'[A-Z]').hasMatch(ch)) {
        filtered += ch;
        si++;
      } else if (slot == 'a') {
        filtered += ch;
        si++;
      }
    }
    String output = '';
    int fi = 0;
    for (final fc in fmt.split('')) {
      if (fi >= filtered.length) break;
      if (fc == '-') {
        output += '-';
      } else {
        output += filtered[fi];
        fi++;
      }
    }
    return TextEditingValue(
      text: output,
      selection: TextSelection.collapsed(offset: output.length),
    );
  }
}

class Role1Screen extends StatefulWidget {
  const Role1Screen({super.key});
  @override
  State<Role1Screen> createState() => _Role1ScreenState();
}

class _Role1ScreenState extends State<Role1Screen> {
  final _formKey = GlobalKey<FormState>();
  String? _userName;
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController retailCustNameController =
      TextEditingController();
  final TextEditingController manufacturingMonthController =
      TextEditingController();
  final TextEditingController manufacturingYearController =
      TextEditingController();
  final TextEditingController expiryYearController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController cascadeNoController = TextEditingController();

  String? selectedVehicleType;
  int? selectedVehicleTypeId;
  String? selectedVehicleFormat;
  String? selectedDealer;
  String? selectedCylinderCapacity;
  int? selectedDealerId;
  String? collectionDate;
  String? lastTestingDate;

  Map<String, String?> pickedImages = {"plate": null};

  bool isVehicleWarning = false;
  bool isRemarkRequired = false;
  String? vehicleWarningMessage;
  bool isCylinderExpired = false;
  bool isEarlyTestingDetected = false;
  bool? isMultiCylinder;
  String? earlyTestingReason;
  final TextEditingController remarksController = TextEditingController();

  Future<void> _checkVehicleNumber(
    String vehicleNo,
    String intervelCount,
  ) async {
    if (vehicleNo.isEmpty) return;
    try {
      final authRepo = context.read<AuthRepository>();
      final userId = await authRepo.getUserId();
      final adminId = await authRepo.getAdminId();
      final provider = context.read<HomeProvider>();

      final now = DateTime.now();
      final fallbackDate =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      final dateToSend = (collectionDate != null && collectionDate!.isNotEmpty)
          ? collectionDate!
          : fallbackDate;

      final data = {
        'vehicleno': vehicleNo,
        'userid': userId ?? '',
        'admin_id': adminId ?? '',
        'intervel_count': intervelCount,
        'collection_date': dateToSend,
        'vehicle_type_id': selectedVehicleTypeId?.toString() ?? '',
      };
      await provider.checkVehicleNumber(data);

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
            _showEarlyTestingWorkflow(message);
          }
        } else {
          if (mounted) {
            setState(() {
              isVehicleWarning = false;
              vehicleWarningMessage = null;
              _removeRemark("Vehicle Alert");
              isMultiCylinder = null;
              earlyTestingReason = null;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Vehicle check error: $e');
    }
  }

  void _showEarlyTestingWorkflow(String message) {
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
            const SizedBox(height: 10),

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
            const SizedBox(height: 20),
            const Text(
              "Is cylinder multi-cylinder?",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                isMultiCylinder = true;
                isRemarkRequired = false;
                try {
                  earlyTestingReason = "Multi-cylinder";
                } catch (e) {}
                _addOrUpdateRemark("Vehicle Alert", popupRemarkCtrl.text);
              });
            },
            child: const Text("Yes", style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                isMultiCylinder = false;
                isRemarkRequired = true;
                try {
                  earlyTestingReason = popupRemarkCtrl.text;
                } catch (e) {}
                _addOrUpdateRemark("Vehicle Alert", popupRemarkCtrl.text);
              });
            },
            child: const Text("No", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _syncExpiryDate() {
    final year = int.tryParse(manufacturingYearController.text);
    if (year != null && manufacturingMonthController.text.isNotEmpty) {
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
      if (monthIndex != -1) {
        final provider = context.read<HomeProvider>();
        final lifeYears = provider.state.selectedProduct?.lifeOfCylinder ?? 20;
        int expiryYearValue = year + lifeYears.toInt();
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
          if (!expired) {
            _removeRemark("Cylinder Expired");
          }
        });
        if (expired) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showExpiredWarningDialog();
          });
        }
      }
    }
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
      final newLines = lines
          .where((line) => !line.startsWith("$title:"))
          .toList();
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
          provider.state.selectedProduct?.intervalTesting ?? 3;

      final thresholdDate = DateTime(
        mfgYear + intervalTesting.toInt(),
        monthIndex + 1,
        1,
      );

      if (testDateTime.isBefore(thresholdDate)) {
        setState(() => isEarlyTestingDetected = true);
        _showEarlyTestingDialog();
      } else {
        setState(() {
          isEarlyTestingDetected = false;
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

  Future<void> _pickAndCompressImage() async {
    final ImagePicker picker = ImagePicker();
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
    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return;
    setState(() => pickedImages["plate"] = image.path);
  }

  late HomeProvider _homeProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeProvider = context.read<HomeProvider>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authRepo = context.read<AuthRepository>();
      final name = await authRepo.getUserName();
      if (mounted) setState(() => _userName = name);
      context.read<HomeProvider>().getVehicleFormat();
      context.read<HomeProvider>().loadHomeData();
      context.read<HomeProvider>().clearDealerAmount();
      context.read<HomeProvider>().clearProductAmount();
    });
  }

  @override
  void dispose() {
    vehicleNumberController.dispose();
    mobileNumberController.dispose();
    manufacturingMonthController.dispose();
    manufacturingYearController.dispose();
    expiryYearController.dispose();
    amountController.dispose();
    cascadeNoController.dispose();
    remarksController.dispose();
    Future.microtask(() {
      _homeProvider.clearProductAmount();
      _homeProvider.clearDealerAmount();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Enter New Certificate",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(
                        Provider.of<ThemeProvider>(context).isDarkMode
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        ).toggleTheme();
                      },
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Text(
                          "Welcome : ",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _userName != null && _userName!.isNotEmpty
                              ? '${_userName![0].toUpperCase()}${_userName!.substring(1).toLowerCase()}'
                              : '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    const HomeSectionHeader(title: "License Details"),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LicenceDetailScreen(),
                        ),
                      ),
                      child: ActionCardNoTitle(
                        child: Column(
                          children: [
                            const HomeRowLabels(
                              l1: "License Name",
                              l2: "Approval No",
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Expanded(
                                  child: HomeValueBox(
                                    text: "PREMIUM HYDRO ENGIN",
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: HomeValueBox(
                                    text: "AG/HQ/GJ/GCT/1G4905",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const HomeSectionHeader(title: "Vehicle Details"),
                    ActionCardNoTitle(
                      child: Column(
                        children: [
                          Consumer<HomeProvider>(
                            builder: (context, provider, _) {
                              final isRetail = provider.state.isRetailCustomer;
                              final dealerList =
                                  provider.state.dealerTypeData?.data ?? [];
                              final dealers = [
                                "Retail Customer",
                                ...dealerList.map((e) => e.fullname ?? ""),
                              ];
                              return Column(
                                children: [
                                  HomeRowLabels(
                                    l1: "Choose Dealer",
                                    l2: isRetail
                                        ? "Retail Customer Name"
                                        : "Mobile Number",
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: HomeDropDownField(
                                          hint:
                                              selectedDealer ?? "Choose Dealer",
                                          items: dealers,
                                          onChanged: (val) {
                                            if (val == null ||
                                                val == "Retail Customer") {
                                              provider.setIsRetailCustomer(
                                                val == "Retail Customer",
                                              );
                                              setState(() {
                                                selectedDealer = val;
                                                selectedDealerId = null;
                                                mobileNumberController.clear();
                                              });
                                              provider.clearDealerAmount();
                                              provider.clearProductAmount();
                                              provider.getVehicleType('rc01');
                                              return;
                                            }
                                            final selected = dealerList
                                                .firstWhere(
                                                  (e) => e.fullname == val,
                                                );
                                            final retail = val
                                                .toLowerCase()
                                                .contains('retail');
                                            provider.setIsRetailCustomer(
                                              retail,
                                            );
                                            setState(() {
                                              selectedDealer = val;
                                              selectedDealerId = selected.id;
                                              if (!retail)
                                                mobileNumberController.text =
                                                    selected.mobileNo ?? '';
                                            });
                                            if (retail) {
                                              provider.clearDealerAmount();
                                              provider.clearProductAmount();
                                              provider.getVehicleType('rc01');
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
                                              provider.getDealerAmount(
                                                selected.id.toString(),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      if (!isRetail)
                                        Expanded(
                                          child: HomeManualField(
                                            hint: "Enter Mobile Number",
                                            controller: mobileNumberController,
                                            keyboardType: TextInputType.phone,
                                            maxLength: 10,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            validator: (val) {
                                              if (val == null || val.isEmpty)
                                                return "Enter Mobile No";
                                              if (val.length != 10)
                                                return "Must be 10 digits";
                                              return null;
                                            },
                                          ),
                                        )
                                      else
                                        Expanded(
                                          child: HomeManualField(
                                            hint: "Enter Customer Name",
                                            controller:
                                                retailCustNameController,
                                            validator: (val) {
                                              if (isRetail &&
                                                  (val == null || val.isEmpty))
                                                return "Required";
                                              return null;
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (isRetail) ...[
                                    const SizedBox(height: 15),
                                    const HomeRowLabels(
                                      l1: "Enter Amount",
                                      l2: "Enter Mobile No.",
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: HomeManualField(
                                            hint: "Enter Amount",
                                            controller: amountController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            validator: (val) {
                                              if (isRetail &&
                                                  (val == null || val.isEmpty))
                                                return "Required";
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: HomeManualField(
                                            hint: "Enter Mobile Number",
                                            controller: mobileNumberController,
                                            keyboardType: TextInputType.phone,
                                            maxLength: 10,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            validator: (val) {
                                              if (val == null || val.isEmpty)
                                                return "Required";
                                              if (val.length != 10)
                                                return "Must be 10 digits";
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
                          const SizedBox(height: 8),
                          Consumer<HomeProvider>(
                            builder: (context, provider, _) {
                              final isVehicleRequired =
                                  provider.state.vehicleRequired;
                              return Column(
                                children: [
                                  HomeRowLabels(
                                    l1: isVehicleRequired
                                        ? "Vehicle Type"
                                        : "Cylinder Capacity",
                                    l2: "Collection Date",
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (isVehicleRequired)
                                        Expanded(
                                          child: Builder(
                                            builder: (context) {
                                              final types =
                                                  provider
                                                      .state
                                                      .vehicleTypeData
                                                      ?.data
                                                      ?.map(
                                                        (e) =>
                                                            e.vehicleName ?? "",
                                                      )
                                                      .toList() ??
                                                  [];
                                              return HomeDropDownField(
                                                hint:
                                                    selectedVehicleType ??
                                                    "Choose Vehicle Type",
                                                items: types,
                                                onChanged: (val) {
                                                  final selected = provider
                                                      .state
                                                      .vehicleTypeData
                                                      ?.data
                                                      ?.firstWhere(
                                                        (e) =>
                                                            e.vehicleName ==
                                                            val,
                                                      );
                                                  setState(() {
                                                    selectedVehicleType = val;
                                                    selectedVehicleTypeId =
                                                        selected?.id;
                                                  });
                                                  provider.clearProductAmount();
                                                  final dId =
                                                      provider
                                                          .state
                                                          .isRetailCustomer
                                                      ? '0'
                                                      : selectedDealerId
                                                            ?.toString();
                                                  if (selected?.id != null &&
                                                      dId != null) {
                                                    provider.getProductAmountByDealer(
                                                      {
                                                        'dealer_id': dId,
                                                        'vehicle_id': selected!
                                                            .id
                                                            .toString(),
                                                        'product_id':
                                                            provider
                                                                .state
                                                                .selectedProduct
                                                                ?.id
                                                                ?.toString() ??
                                                            '',
                                                      },
                                                    );
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        )
                                      else
                                        Expanded(
                                          child: Builder(
                                            builder: (context) {
                                              final capacities =
                                                  provider
                                                      .state
                                                      .vehicleTypeData
                                                      ?.cylinderCapacity
                                                      ?.map(
                                                        (e) =>
                                                            e.cylinderCapacity ??
                                                            "",
                                                      )
                                                      .where(
                                                        (e) =>
                                                            e.isNotEmpty &&
                                                            e != 'null',
                                                      )
                                                      .toList() ??
                                                  [];
                                              if (capacities.isEmpty) {
                                                return const HomeDropDownField(
                                                  hint: "N/A",
                                                  items: [],
                                                );
                                              }
                                              return HomeDropDownField(
                                                hint:
                                                    selectedCylinderCapacity ??
                                                    "Select Capacity",
                                                items: capacities,
                                                onChanged: (val) {
                                                  setState(() {
                                                    selectedCylinderCapacity =
                                                        val;
                                                  });
                                                  provider.clearProductAmount();
                                                  final dId =
                                                      provider
                                                          .state
                                                          .isRetailCustomer
                                                      ? '0'
                                                      : selectedDealerId
                                                            ?.toString();
                                                  if (dId != null) {
                                                    provider
                                                        .getProductAmountByDealer({
                                                          'dealer_id': dId,
                                                          'vehicle_id': '',
                                                          'cylinder_capacity':
                                                              val,
                                                          'product_id':
                                                              provider
                                                                  .state
                                                                  .selectedProduct
                                                                  ?.id
                                                                  ?.toString() ??
                                                              '',
                                                        });
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: HomeDatePickerField(
                                          label: "Collection Date",
                                          displayDate: collectionDate,
                                          onTap: () async {
                                            final date = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime.now(),
                                            );
                                            if (date != null)
                                              setState(
                                                () => collectionDate =
                                                    "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}",
                                              );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Consumer<HomeProvider>(
                            builder: (context, provider, _) {
                              if (provider.state.productAmountStatus ==
                                      HomeStatus.success &&
                                  provider.state.productAmount != null &&
                                  (selectedVehicleTypeId != null ||
                                      !provider.state.vehicleRequired)) {
                                return Column(
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
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(height: 15),
                          Builder(
                            builder: (context) {
                              final provider = context.watch<HomeProvider>();
                              if (!provider.state.vehicleRequired) {
                                return const SizedBox.shrink();
                              }

                              final productName =
                                  provider.state.selectedProduct?.fullname
                                      ?.toLowerCase() ??
                                  '';
                              final isCNG =
                                  productName.contains('cng') ||
                                  (productName.contains('compress') &&
                                      productName.contains('natural') &&
                                      productName.contains('gas'));
                              final isOxygen = productName.contains('oxygen');

                              if (selectedVehicleType?.toLowerCase().contains(
                                    'cascade',
                                  ) ??
                                  false) {
                                return Column(
                                  children: [
                                    const HomeRowLabels(
                                      l1: "Enter Cascade Number",
                                      l2: "",
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: HomeManualField(
                                            hint: "Enter Cascade Number",
                                            controller: cascadeNoController,
                                            validator: (val) =>
                                                (val == null || val.isEmpty)
                                                ? "Required"
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Expanded(child: SizedBox()),
                                      ],
                                    ),
                                  ],
                                );
                              } else if (isCNG || isOxygen) {
                                return Column(
                                  children: [
                                    const HomeRowLabels(
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
                                                      ?.map(
                                                        (e) => e.vFormat ?? "",
                                                      )
                                                      .toList() ??
                                                  [];
                                              return HomeDropDownField(
                                                hint:
                                                    selectedVehicleFormat ??
                                                    "CHOOSE VEHICLE FOR",
                                                items: formats,
                                                onChanged: (val) => setState(
                                                  () => selectedVehicleFormat =
                                                      val,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: HomeManualField(
                                            hint: "ENTER VEHICLE NO.",
                                            controller: vehicleNumberController,
                                            textCapitalization:
                                                TextCapitalization.characters,
                                            keyboardType:
                                                (selectedVehicleFormat !=
                                                        null &&
                                                    !selectedVehicleFormat!
                                                        .toUpperCase()
                                                        .contains('X'))
                                                ? TextInputType.number
                                                : TextInputType.visiblePassword,
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
                                            onChanged: (val) {
                                              if (val.length >= 6) {
                                                final intervalCount =
                                                    context
                                                        .read<HomeProvider>()
                                                        .state
                                                        .selectedProduct
                                                        ?.intervalTesting ??
                                                    '';
                                                _checkVehicleNumber(
                                                  val,
                                                  intervalCount.toString(),
                                                );
                                              }
                                            },
                                            validator: (val) =>
                                                (val == null || val.isEmpty)
                                                ? "Required"
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    const HomeSectionHeader(title: "Product Details"),
                    ActionCardNoTitle(
                      child: Consumer<HomeProvider>(
                        builder: (context, provider, _) {
                          final product = provider.state.selectedProduct;
                          return Column(
                            children: [
                              const HomeRowLabels(
                                l1: "Product Type",
                                l2: "Cylinder Specification",
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: HomeValueBox(
                                      text: product?.fullname ?? "Loading...",
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: HomeValueBox(
                                      text:
                                          provider.state.selectedCylinderType ??
                                          product?.standard ??
                                          "Loading...",
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Manufacturing Date",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.textTheme.bodyLarge?.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: HomeDatePickerField(
                                      label: "Month",
                                      displayDate:
                                          manufacturingMonthController
                                              .text
                                              .isEmpty
                                          ? null
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
                                                    final monthNumber =
                                                        index + 1;
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
                                                            DateTime.now()
                                                                .month;
                                                    return ListTile(
                                                      title: Text(
                                                        monthName,
                                                        style: TextStyle(
                                                          color: isFutureMonth
                                                              ? Colors.grey
                                                              : theme
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.color,
                                                        ),
                                                      ),
                                                      enabled: !isFutureMonth,
                                                      onTap: isFutureMonth
                                                          ? null
                                                          : () {
                                                              setState(
                                                                () =>
                                                                    manufacturingMonthController
                                                                            .text =
                                                                        monthName,
                                                              );
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                              WidgetsBinding
                                                                  .instance
                                                                  .addPostFrameCallback(
                                                                    (_) =>
                                                                        _checkIntervalWarning(),
                                                                  );
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
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: HomeDatePickerField(
                                      label: "Year",
                                      displayDate:
                                          manufacturingYearController
                                              .text
                                              .isEmpty
                                          ? null
                                          : manufacturingYearController.text,
                                      validator: (v) =>
                                          (manufacturingYearController
                                              .text
                                              .isEmpty)
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
                                                      final now =
                                                          DateTime.now();
                                                      if (dateTime.year ==
                                                          now.year) {
                                                        final monthText =
                                                            manufacturingMonthController
                                                                .text;
                                                        if (monthText
                                                            .isNotEmpty) {
                                                          const List<String>
                                                          mNames = [
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
                                                          int mIdx = mNames
                                                              .indexOf(
                                                                monthText,
                                                              );
                                                          if (mIdx + 1 >
                                                              now.month)
                                                            manufacturingMonthController
                                                                    .text =
                                                                "";
                                                        }
                                                      }
                                                    });
                                                    Navigator.pop(context);
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback((
                                                          _,
                                                        ) {
                                                          _checkIntervalWarning();
                                                          _syncExpiryDate();
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
                              const SizedBox(height: 15),
                              const HomeRowLabels(
                                l1: "Expiry Date",
                                l2: "Certificate Result",
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: HomeValueBox(
                                      text: expiryYearController.text.isEmpty
                                          ? "Auto Calculated"
                                          : (() {
                                              try {
                                                final parts =
                                                    expiryYearController.text
                                                        .split("-");
                                                if (parts.length >= 2) {
                                                  final monthInt = int.tryParse(
                                                    parts[0],
                                                  );
                                                  final year = parts[1];
                                                  if (monthInt != null &&
                                                      monthInt >= 1 &&
                                                      monthInt <= 12) {
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
                                                    return "${mNames[monthInt - 1]} $year";
                                                  }
                                                }
                                                return expiryYearController
                                                    .text;
                                              } catch (e) {
                                                return expiryYearController
                                                    .text;
                                              }
                                            })(),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: HomeValueBox(
                                      text:
                                          (isVehicleWarning ||
                                              isCylinderExpired ||
                                              isEarlyTestingDetected)
                                          ? "FAIL"
                                          : "PASS",
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (isRemarkRequired ||
                        remarksController.text.trim().isNotEmpty) ...[
                      const HomeSectionHeader(title: "Remarks"),
                      ActionCardNoTitle(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isVehicleWarning)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  vehicleWarningMessage ??
                                      "Vehicle alert detected.",
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
                            FormField<String>(
                              validator: (v) {
                                if (isRemarkRequired &&
                                    remarksController.text.trim().isEmpty) {
                                  return "Remark is required.";
                                }
                                return null;
                              },
                              builder: (state) {
                                final lines = remarksController.text
                                    .split('\n')
                                    .where((e) => e.trim().isNotEmpty)
                                    .toList();
                                final theme = Theme.of(context);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...lines.map((line) {
                                      int colonIndex = line.indexOf(':');
                                      String title = colonIndex != -1
                                          ? line.substring(0, colonIndex).trim()
                                          : "Remark";
                                      String desc = colonIndex != -1
                                          ? line
                                                .substring(colonIndex + 1)
                                                .trim()
                                          : line;
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: theme.colorScheme.primary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    title,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: theme
                                                          .colorScheme
                                                          .primary,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    desc,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              icon: Icon(
                                                Icons.edit,
                                                size: 16,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                              onPressed: () {
                                                _editRemarkDialog(title, desc);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    if (state.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          state.errorText!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Consumer<HomeProvider>(
                      builder: (context, provider, _) {
                        if (!provider.state.photoRequired)
                          return const SizedBox.shrink();
                        return Column(
                          children: [
                            const HomeSectionHeader(title: "Photo Uploads"),
                            ActionCardNoTitle(
                              child: DashedUploadArea(
                                title: "Capture Photo of Number Plate",
                                onPick: _pickAndCompressImage,
                                imagePath: pickedImages["plate"],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    Consumer<HomeProvider>(
                      builder: (context, provider, _) {
                        final status = provider.state.certificateStatus;
                        return CustomButton(
                          text: isCylinderExpired
                              ? "Submit Rejected Certificate"
                              : "Submit Certificate",
                          isLoading: status == HomeStatus.loading,
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
                            final bool isCascade =
                                selectedVehicleType?.toLowerCase().contains(
                                  'cascade',
                                ) ??
                                false;
                            if (!isCascade &&
                                provider.state.photoRequired &&
                                pickedImages["plate"] == null) {
                              CustomToast.error(
                                context,
                                "Please capture Number Plate photo",
                                top: true,
                              );
                              return;
                            }
                            final authRepo = context.read<AuthRepository>();
                            final userId = await authRepo.getUserId();
                            final adminId = await authRepo.getAdminId();
                            final Map<String, dynamic> data = {
                              'vehicle_number': vehicleNumberController.text,
                              'license_name': 'PREMIUM HYDRO ENGINEERING',
                              'approval_no': 'AG/HQ/GJ/GCT/1G49051',
                              'vehicle_type':
                                  selectedVehicleTypeId?.toString() ?? '',
                              'collection_date': collectionDate,
                              'vehicle_format': selectedVehicleFormat ?? '',
                              'cascade_no': cascadeNoController.text,
                              'cylinder_capacity':
                                  selectedCylinderCapacity ?? '',
                              'certificate_pass_fail':
                                  (isVehicleWarning ||
                                      isCylinderExpired ||
                                      isEarlyTestingDetected)
                                  ? 'FAIL'
                                  : 'PASS',
                              'payment_amount': provider.state.isRetailCustomer
                                  ? amountController.text
                                  : (provider.state.productAmount ?? ''),

                              'product_type':
                                  provider.state.selectedProduct?.fullname ??
                                  '',
                              'specification':
                                  provider.state.selectedCylinderType ??
                                  provider.state.selectedProduct?.standard ??
                                  '',
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
                                String monthStr = manufacturingMonthController
                                    .text
                                    .trim();
                                if (RegExp(r'^\d+$').hasMatch(monthStr))
                                  return '${monthStr.padLeft(2, '0')}-${manufacturingYearController.text}';
                                int mIdx = mNames.indexOf(monthStr);
                                String mm = (mIdx != -1)
                                    ? (mIdx + 1).toString().padLeft(2, '0')
                                    : '01';
                                return '$mm-${manufacturingYearController.text}';
                              }(),
                              'working_pressure':
                                  provider
                                      .state
                                      .selectedProduct
                                      ?.workingPressure ??
                                  '',
                              'test_pressure':
                                  provider
                                      .state
                                      .selectedProduct
                                      ?.testingPressure ??
                                  '',
                              'dealer_id': provider.state.isRetailCustomer
                                  ? 'rc01'
                                  : (selectedDealerId?.toString() ?? ''),
                              'mobile_no': mobileNumberController.text,
                              if (provider.state.isRetailCustomer)
                                'retail_cust_name':
                                    retailCustNameController.text,
                              'last_test_date': lastTestingDate ?? '',
                              'user_id': userId ?? '',
                              'admin_id': adminId ?? '',
                              'remark': remarksController.text,
                              if (provider.state.isRetailCustomer)
                                'retail_amount': amountController.text
                              else
                                'amount': provider.state.productAmount ?? '',
                              'is_multi_cylinder':
                                  isMultiCylinder?.toString() ?? '',
                              'early_testing_reason': earlyTestingReason ?? '',
                              'name': pickedImages['plate'] != null
                                  ? pickedImages['plate']!.split('/').last
                                  : 'no_image.jpg',
                              'photo_path': pickedImages['plate'],
                            };
                            bool success;
                            if (isCylinderExpired) {
                              final rejectedData = {
                                'vehicle_number': data['vehicle_number'],
                                'license_name': data['license_name'],
                                'approval_no': data['approval_no'],
                                'vehicle_type': data['vehicle_type'],
                                'vehicle_format': data['vehicle_format'],
                                'test_date': data['collection_date'],
                                'Payment_amount': data['Payment_amount'],
                                'next_test_date': '',
                                'product_type': data['product_type'],
                                'specification': data['specification'],
                                'cylinder_capacity': data['cylinder_capacity'],
                                'certificate_pass_fail':
                                    data['certificate_status'],
                                'manufacturing_date':
                                    data['manufacturing_date'],
                                'cascade_no': data['cascade_no'],
                                'cylinder_no': '',
                                'cylinder_make': '',
                                'cce_filling_permission_no': '',
                                'filling_permission_date': '',
                                'expire_date': expiryYearController.text.trim(),
                                'last_test_date': data['last_test_date'],
                                'rejected_water_capacity': '',
                                'admin_id': data['admin_id'],
                                'user_id': data['user_id'],
                                'rcp': pickedImages['plate'],
                                if (provider.state.isRetailCustomer)
                                  'retail_amount': data['retail_amount']
                                else
                                  'amount': data['amount'],

                                'dealer_name': provider.state.isRetailCustomer
                                    ? 'rc01'
                                    : data['dealer_id'],
                                'mobile_no': data['mobile_no'],
                                if (provider.state.isRetailCustomer)
                                  'retail_cust_name': data['retail_cust_name'],
                              };
                              success = await provider.submitRejectedCylinder(
                                rejectedData,
                                context,
                              );
                            } else {
                              success = await provider.submitRole1Certificate(
                                data,
                                context,
                              );
                            }
                            print('==========>RequestData: $data');

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
                                            isCylinderExpired
                                                ? "Rejected cylinder recorded successfully."
                                                : "Certificate created successfully.",
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
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const Role1CertificateListScreen(),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                              ),
                                              child: const Text(
                                                "Continue",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
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
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editRemarkDialog(String title, String currentDesc) {
    TextEditingController editCtrl = TextEditingController(text: currentDesc);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          "Edit $title",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: editCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: "Remark",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
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
                _addOrUpdateRemark(title, editCtrl.text);
              });
            },
            child: const Text(
              "Save",
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
}

class ActionCardNoTitle extends StatelessWidget {
  final Widget child;
  const ActionCardNoTitle({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.2 : 0.03,
            ),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
