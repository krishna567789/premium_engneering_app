import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:premium_engneering_app/features/home/provider/home_state.dart';
import 'role2_certificate_list_screen.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import 'package:premium_engneering_app/core/theme_provider.dart';
import '../../../widgets/custom_widgets.dart';
import '../provider/home_provider.dart';
import '../widgets/home_components.dart';
import 'licence_detail.dart';
import 'role1_screen.dart';
import '../../../core/theme.dart';
import '../../auth/data/auth_repository.dart';

class VehicleNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length < oldValue.text.length) return newValue;
    String text = newValue.text.toUpperCase().replaceAll('-', '');
    String out = "";
    for (int i = 0; i < text.length; i++) {
      out += text[i];
      if (i == 1 || i == 3 || i == 5) if (i != text.length - 1) out += "-";
    }
    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: out.length),
    );
  }
}

class Role2Screen extends StatefulWidget {
  const Role2Screen({super.key});
  @override
  State<Role2Screen> createState() => _Role2ScreenState();
}

class _Role2ScreenState extends State<Role2Screen> {
  final _formKey = GlobalKey<FormState>();
  String? _userName;
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController retailCustNameController =
      TextEditingController();
  final TextEditingController serialNoController = TextEditingController();
  final TextEditingController cceNoController = TextEditingController();
  final TextEditingController manufacturingMonthController =
      TextEditingController();
  final TextEditingController manufacturingYearController =
      TextEditingController();

  bool get _isTestingBeforeMfg {
    if (lastTestingDate == null ||
        manufacturingMonthController.text.isEmpty ||
        manufacturingYearController.text.isEmpty)
      return false;
    try {
      final testParts = lastTestingDate!.split('-');
      if (testParts.length == 3) {
        int testMonth = int.parse(testParts[1]);
        int testYear = int.parse(testParts[2]);
        int mfgYear = int.parse(manufacturingYearController.text);
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
        int mfgMonth = mNames.indexOf(manufacturingMonthController.text) + 1;
        if (mfgMonth == 0) return false;
        if (testYear < mfgYear) return true;
        if (testYear == mfgYear && testMonth < mfgMonth) return true;
      }
    } catch (_) {}
    return false;
  }

  final TextEditingController expiryYearController = TextEditingController();
  final TextEditingController cascadeNoController = TextEditingController();
  final TextEditingController initialObsController = TextEditingController();
  final TextEditingController visualObsController = TextEditingController();
  final TextEditingController threadingObsController = TextEditingController();
  final TextEditingController internalObsController = TextEditingController();
  final TextEditingController tareWeightController = TextEditingController();
  final TextEditingController actualWeightController = TextEditingController();
  final TextEditingController weightLossKgController = TextEditingController();
  final TextEditingController weightLossPctController = TextEditingController();
  final TextEditingController cylinderSizeController = TextEditingController();
  final TextEditingController shellMinController = TextEditingController();
  final TextEditingController shellObsController = TextEditingController();
  final TextEditingController bottomMinController = TextEditingController();
  final TextEditingController bottomObsController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController expansionInitialController =
      TextEditingController();
  final TextEditingController expansionTotalController =
      TextEditingController();
  final TextEditingController expansionPermController = TextEditingController();
  final TextEditingController expansionPctController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  String? selectedVehicleType;
  int? selectedVehicleTypeId;
  String? selectedVehicleFormat;
  String? selectedDealer;
  int? selectedDealerId;
  String? selectedCylinderMakeId;
  String? selectedCylinderMakeName;
  String? selectedResult = "PASS";
  String? testDate;
  String? nextTestDate;
  String? lastTestingDate;
  String? fillingPermDate;
  String? weightErrorMessage;
  String? shellThicknessError;
  String? bottomThicknessError;
  bool isCylinderExpired = false;
  bool isEarlyTestingDetected = false;
  bool isVehicleWarning = false;
  bool isRemarkRequired = false;
  String? vehicleWarningMessage;
  bool? isMultiCylinder;
  String? earlyTestingReason;
  final TextEditingController amountController = TextEditingController();

  String? initialStatus = "OK";
  String? visualStatus = "OK";
  String? threadingStatus = "OK";
  String? internalStatus = "OK";
  String? plateStatus = "OK";

  final Map<String, String?> pickedImages = {"plate": null, "neck": null};
  final FocusNode tareWeightFocus = FocusNode();
  final FocusNode actualWeightFocus = FocusNode();

  void _checkShellThickness() {
    double? min = double.tryParse(shellMinController.text);
    double? obs = double.tryParse(shellObsController.text);
    setState(
      () => shellThicknessError = (min != null && obs != null && obs < min)
          ? "Observed thickness cannot be less than Minimum Calculate"
          : null,
    );
  }

  void _checkBottomThickness() {
    double? min = double.tryParse(bottomMinController.text);
    double? obs = double.tryParse(bottomObsController.text);
    setState(
      () => bottomThicknessError = (min != null && obs != null && obs < min)
          ? "Observed thickness cannot be less than Minimum Calculate"
          : null,
    );
  }

  Future<void> _pickAndCompressImage(String key) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) {
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null)
        setState(() => pickedImages[key] = pickedFile.path);
    }
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
      int monthIndex = mNames.indexOf(manufacturingMonthController.text);
      if (monthIndex != -1) {
        final provider = context.read<HomeProvider>();
        final lifeYears = provider.state.selectedProduct?.lifeOfCylinder ?? 20;
        int expiryYearValue = year + lifeYears.toInt();
        String month = (monthIndex + 1).toString().padLeft(2, '0');
        DateTime now = DateTime.now();
        bool expired =
            (expiryYearValue < now.year) ||
            (expiryYearValue == now.year && (monthIndex + 1) < now.month);
        setState(() {
          expiryYearController.text = "$month-$expiryYearValue";
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

  void _syncFillingPermDate() {
    if (manufacturingMonthController.text.isNotEmpty &&
        manufacturingYearController.text.isNotEmpty) {
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
      int monthIndex = mNames.indexOf(manufacturingMonthController.text);
      if (monthIndex != -1) {
        String month = (monthIndex + 1).toString().padLeft(2, '0');
        setState(
          () =>
              fillingPermDate = "01-$month-${manufacturingYearController.text}",
        );
      }
    }
  }

  late HomeProvider _homeProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeProvider = context.read<HomeProvider>();
  }

  bool _tareWasFocused = false;
  bool _actualWasFocused = false;

  @override
  void initState() {
    super.initState();
    tareWeightFocus.addListener(_onWeightFocusChange);
    actualWeightFocus.addListener(_onWeightFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authRepo = context.read<AuthRepository>();
      final name = await authRepo.getUserName();
      if (mounted) setState(() => _userName = name);
      context.read<HomeProvider>().getVehicleFormat();
      context.read<HomeProvider>().loadHomeData();
      context.read<HomeProvider>().getCylinderMake();
      context.read<HomeProvider>().clearDealerAmount();
      context.read<HomeProvider>().clearProductAmount();
    });
  }

  void _onWeightFocusChange() {
    if (_tareWasFocused && !tareWeightFocus.hasFocus) _triggerWeightWarning();
    if (_actualWasFocused && !actualWeightFocus.hasFocus)
      _triggerWeightWarning();
    _tareWasFocused = tareWeightFocus.hasFocus;
    _actualWasFocused = actualWeightFocus.hasFocus;
  }

  @override
  void dispose() {
    tareWeightFocus.removeListener(_onWeightFocusChange);
    actualWeightFocus.removeListener(_onWeightFocusChange);
    tareWeightFocus.dispose();
    actualWeightFocus.dispose();
    vehicleNumberController.dispose();
    mobileNumberController.dispose();
    serialNoController.dispose();
    cceNoController.dispose();
    manufacturingMonthController.dispose();
    manufacturingYearController.dispose();
    expiryYearController.dispose();
    cascadeNoController.dispose();
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
    capacityController.dispose();
    expansionInitialController.dispose();
    expansionTotalController.dispose();
    expansionPermController.dispose();
    expansionPctController.dispose();
    remarksController.dispose();
    amountController.dispose();
    _homeProvider.clearProductAmount();
    _homeProvider.clearDealerAmount();
    super.dispose();
  }

  Future<void> _checkVehicleNumber(
    String vehicleNo,
    String intervel_count,
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
      final cDate = (testDate != null && testDate!.isNotEmpty)
          ? testDate!
          : fallbackDate;
      await provider.checkVehicleNumber({
        'vehicleno': vehicleNo,
        'userid': userId ?? '',
        'admin_id': adminId ?? '',
        'intervel_count': intervel_count,
        'collection_date': cDate,
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
            _showEarlyTestingWorkflow(message);
          }
        } else {
          if (mounted)
            setState(() {
              isVehicleWarning = false;
              vehicleWarningMessage = null;
              isRemarkRequired = false;
              isMultiCylinder = null;
              earlyTestingReason = null;
            });
        }
      }
    } catch (e) {
      debugPrint('Vehicle check error: $e');
    }
  }

  void _showEarlyTestingWorkflow(String message) {
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
            Text(message, style: const TextStyle(fontSize: 14)),
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
                earlyTestingReason = "Multi-cylinder";
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
              });
              _showReasonInputDialog();
            },
            child: const Text("No", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showReasonInputDialog() {
    final TextEditingController reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Enter Reason"),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(
            hintText: "Why is it here early?",
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              if (reasonCtrl.text.isNotEmpty) {
                setState(() {
                  earlyTestingReason = reasonCtrl.text;
                  remarksController.text = reasonCtrl.text;
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }

  void _calculateWeightLoss() {
    final originalStr = tareWeightController.text.trim();
    final actualStr = actualWeightController.text.trim();
    if (originalStr.isNotEmpty && actualStr.isNotEmpty) {
      double original = double.tryParse(originalStr) ?? 0.0;
      double actual = double.tryParse(actualStr) ?? 0.0;
      if (original > 0) {
        double loss = original - actual;
        double percentage = (loss / original) * 100;
        setState(() {
          weightLossKgController.text = loss.toStringAsFixed(2);
          weightLossPctController.text = percentage.toStringAsFixed(2);
          weightErrorMessage = percentage > 5.0
              ? "Loss of weight exceeds 5%. Cylinder may be rejected."
              : null;
        });
      }
    } else {
      setState(() {
        weightLossKgController.text = "";
        weightLossPctController.text = "";
        weightErrorMessage = null;
      });
    }
  }

  void _triggerWeightWarning() {
    _calculateWeightLoss();
    if (weightErrorMessage != null)
      _showWeightWarningDialog(weightErrorMessage!);
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
          selectedResult = percentage > 10.0 ? "FAIL" : "PASS";
        });
      }
    } else {
      setState(() => expansionPctController.text = "");
    }
  }

  void _checkIntervalWarning() {
    if (testDate == null ||
        manufacturingMonthController.text.isEmpty ||
        manufacturingYearController.text.isEmpty)
      return;
    try {
      final testParts = testDate!.split("-");
      if (testParts.length != 3) return;
      final testDateTime = DateTime(
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
      int monthIndex = mNames.indexOf(manufacturingMonthController.text);
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
        setState(() => isEarlyTestingDetected = false);
      }
    } catch (e) {
      debugPrint("Error checking interval: $e");
    }
  }

  Future<void> _checkLastTestingDateValidation() async {
    if (testDate == null || lastTestingDate == null) return;
    try {
      final provider = context.read<HomeProvider>();
      final interval = provider.state.selectedProduct?.intervalTesting ?? 3;

      // Construct manufacturing date in DD-MM-YYYY format (defaulting to 01 as day)
      String mfgDate = "";
      if (manufacturingMonthController.text.isNotEmpty &&
          manufacturingYearController.text.isNotEmpty) {
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
        int mIdx = mNames.indexOf(manufacturingMonthController.text) + 1;
        if (mIdx > 0) {
          mfgDate =
              "01-${mIdx.toString().padLeft(2, '0')}-${manufacturingYearController.text}";
        }
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final response = await provider.checkLastTestingDate({
        'test_date': testDate,
        'last_testing_date': lastTestingDate,
        'manufacturing_date': mfgDate,
        'interval': interval.toString(),
      });

      if (mounted) Navigator.pop(context);

      if (response != null &&
          (response['status'] == false ||
              response['status'] == 'false' ||
              response['status'] == 'error')) {
        String msg = response['message'] ??
            "Before test date is not great then last testing date";
        setState(() {
          isRemarkRequired = true;
          remarksController.text = msg;
        });
        _showLastTestingDateWarningDialog(msg);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      debugPrint("Error calling last testing date API: $e");
    }
  }

  void _showLastTestingDateWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text("Alert"),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
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

  void _showEarlyTestingDialog() {
    const String message =
        "You’ve come in for testing earlier than the scheduled interval. If you proceed, you must provide a reason in the Remarks field below.";
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
        content: const Text(message, style: TextStyle(fontSize: 16)),
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
                    Text(
                      "Welcome : ${_userName ?? "Role2"}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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
                      child: const ActionCardNoTitle(
                        child: Column(
                          children: [
                            HomeRowLabels(
                              l1: "License Name",
                              l2: "Approval No",
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: HomeValueBox(
                                    text: "PREMIUM HYDRO ENGIN",
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
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
                    const HomeSectionHeader(title: "Vehicle Details"),
                    ActionCardNoTitle(
                      child: Column(
                        children: [
                          _buildDealerAndMobileSection(),
                          const SizedBox(height: 15),
                          const HomeRowLabels(
                            l1: "Vehicle Type",
                            l2: "Test Date",
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _buildVehicleTypeDropdown()),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildDatePicker("Test Date", testDate, (
                                  d,
                                ) {
                                  setState(() {
                                    testDate = d;
                                    if (d != null && d.contains("-")) {
                                      try {
                                        final p = d.split("-");
                                        final date = DateTime(
                                          int.parse(p[2]),
                                          int.parse(p[1]),
                                          int.parse(p[0]),
                                        );
                                        final nextDate = DateTime(
                                          date.year + 3,
                                          date.month,
                                          date.day,
                                        ).subtract(const Duration(days: 1));
                                        nextTestDate =
                                            "${nextDate.day.toString().padLeft(2, '0')}-${nextDate.month.toString().padLeft(2, '0')}-${nextDate.year}";
                                      } catch (e) {}
                                    }
                                  });
                                  _checkIntervalWarning();
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildProductAmountDisplay(),
                          const SizedBox(height: 8),
                          Builder(
                            builder: (context) {
                              final provider = context.watch<HomeProvider>();
                              final productName = provider.state.selectedProduct?.fullname?.toLowerCase() ?? '';
                            final isCNG = productName.contains('cng') || (productName.contains('compress') && productName.contains('natural') && productName.contains('gas'));
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
                                              ? ""
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
                                          child: _buildVehicleFormatDropdown(),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: HomeManualField(
                                            hint: "ENTER VEHICLE NU",
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
                                                (selectedVehicleFormat?.isNotEmpty == true)
                                                    ? selectedVehicleFormat!.length
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
                                                    "";
                                                _checkVehicleNumber(
                                                  val,
                                                  intervalCount.toString(),
                                                );
                                              }
                                            },
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
                          const HomeRowLabels(l1: "Next Test Due Date", l2: ""),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: HomeValueBox(
                                  text: nextTestDate ?? "Auto Calculated",
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const HomeSectionHeader(title: "Product Details"),
                    ActionCardNoTitle(
                      child: Column(
                        children: [
                          const HomeRowLabels(
                            l1: "Product Type",
                            l2: "Cylinder Specification",
                          ),
                          const SizedBox(height: 8),
                          _buildProductDetailsRow(),
                          const SizedBox(height: 15),
                          const HomeRowLabels(
                            l1: "Serial Number Cylinder",
                            l2: "Manufacturing Date",
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: HomeManualField(
                                  hint: "Cylinder Serial No",
                                  controller: serialNoController,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: HomeDatePickerField(
                                        label: "Month",
                                        showIcon: false,
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
                                            ? ""
                                            : null,
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              final List<String> mNames = [
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
                                                    itemBuilder: (context, index) {
                                                      final monthName =
                                                          mNames[index];
                                                      final monthNumber =
                                                          index + 1;
                                                      int? sYear = int.tryParse(
                                                        manufacturingYearController
                                                            .text,
                                                      );
                                                      bool isCurrentYear =
                                                          sYear == null ||
                                                          sYear ==
                                                              DateTime.now()
                                                                  .year;
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
                                      child: HomeDatePickerField(
                                        label: "Year",
                                        showIcon: false,
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
                                            ? ""
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
                                                    onChanged: (DateTime dateTime) {
                                                      setState(() {
                                                        manufacturingYearController
                                                            .text = dateTime
                                                            .year
                                                            .toString();
                                                        final now =
                                                            DateTime.now();
                                                        if (dateTime.year ==
                                                            now.year) {
                                                          final mText =
                                                              manufacturingMonthController
                                                                  .text;
                                                          if (mText
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
                                                                .indexOf(mText);
                                                            if (mIdx + 1 >
                                                                now.month)
                                                              manufacturingMonthController
                                                                      .text =
                                                                  "";
                                                          }
                                                        }
                                                        _syncFillingPermDate();
                                                        _syncExpiryDate();
                                                      });
                                                      Navigator.pop(context);
                                                      _checkIntervalWarning();
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
                          const HomeRowLabels(
                            l1: "Cylinder Make",
                            l2: "Last Testing Date",
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildCylinderMakeDropdown(
                                  validator: (v) =>
                                      (selectedCylinderMakeId == null)
                                      ? ""
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildDatePicker(
                                  "Last Test Date",
                                  lastTestingDate,
                                  (d) {
                                    setState(() => lastTestingDate = d);
                                    _checkLastTestingDateValidation();
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
                          const HomeRowLabels(
                            l1: "CCE No",
                            l2: "Filling Permission Date",
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: HomeManualField(
                                  hint: "Enter CCE Number",
                                  controller: cceNoController,
                                  validator: (v) =>
                                      (v == null || v.isEmpty) ? "" : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildDatePicker(
                                  "Permission Date",
                                  fillingPermDate,
                                  (d) => setState(() => fillingPermDate = d),
                                  validator: (v) =>
                                      (fillingPermDate == null) ? "" : null,
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
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    HomeValueBox(
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
                                  ],
                                ),
                              ),
                              if (isCylinderExpired) ...[
                                const SizedBox(width: 10),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: const Text(
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
                        ],
                      ),
                    ),
                    if (!isCylinderExpired) ...[
                      const HomeSectionHeader(title: "Testing Details"),
                      ActionCardNoTitle(
                        child: Column(
                          children: [
                            _buildInspectionRow(
                              "Valve Inspection",
                              "Visual Inspection",
                              initialStatus,
                              visualStatus,
                              initialObsController,
                              visualObsController,
                              (v) => setState(() => initialStatus = v),
                              (v) => setState(() => visualStatus = v),
                            ),
                            _buildInspectionRow(
                              "Cylinder Threading",
                              "Internal Inspection",
                              threadingStatus,
                              internalStatus,
                              threadingObsController,
                              internalObsController,
                              (v) => setState(() => threadingStatus = v),
                              (v) => setState(() => internalStatus = v),
                            ),
                            const SizedBox(height: 15),
                            const HomeRowLabels(
                              l1: "Original T.W (Stamped Weight)",
                              l2: "Actual Weight (Measured Weight)",
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: HomeManualField(
                                    hint: "Original Tare Weigh",
                                    keyboardType: TextInputType.number,
                                    controller: tareWeightController,
                                    focusNode: tareWeightFocus,
                                    onChanged: (_) => _calculateWeightLoss(),
                                    onFieldSubmitted: (_) =>
                                        _triggerWeightWarning(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: HomeManualField(
                                    hint: "Actual Weight",
                                    controller: actualWeightController,
                                    keyboardType: TextInputType.number,
                                    focusNode: actualWeightFocus,
                                    onChanged: (_) => _calculateWeightLoss(),
                                    onFieldSubmitted: (_) =>
                                        _triggerWeightWarning(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            const HomeRowLabels(
                              l1: "Loss Of Weight(Kg...)",
                              l2: "Loss Of Weight(%)",
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      HomeValueBox(
                                        text:
                                            weightLossKgController.text.isEmpty
                                            ? "0.00"
                                            : weightLossKgController.text,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      HomeValueBox(
                                        text:
                                            weightLossPctController.text.isEmpty
                                            ? "0.00%"
                                            : "${weightLossPctController.text}%",
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (weightErrorMessage != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
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
                                ),
                              ),
                            ],
                            const SizedBox(height: 15),
                            const HomeRowLabels(
                              l1: "Plate Condition",
                              l2: "Dia of The Cylinder(mm)",
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: HomeDropDownField(
                                    hint: plateStatus ?? "OK",
                                    items: const ["OK", "Not OK"],
                                    onChanged: (v) =>
                                        setState(() => plateStatus = v),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: HomeManualField(
                                    hint: "Size Of The Cylinder",
                                    controller: cylinderSizeController,
                                    validator: (v) =>
                                        (v == null || v.isEmpty) ? "" : null,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const HomeSectionHeader(title: "Cylinder Wall Thickness"),
                      ActionCardNoTitle(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Shell (mm)",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodySmall?.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const HomeRowLabels(
                              l1: "Minimum Calculate",
                              l2: "Observed Thickness",
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: HomeManualField(
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
                                  child: HomeManualField(
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
                            if (shellThicknessError != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        shellThicknessError!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                            const HomeRowLabels(
                              l1: "Minimum Calculate",
                              l2: "Observed Thickness",
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: HomeManualField(
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
                                  child: HomeManualField(
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
                            if (bottomThicknessError != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        bottomThicknessError!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const HomeSectionHeader(title: "Testing Result"),
                    ActionCardNoTitle(
                      child: Consumer<HomeProvider>(
                        builder: (context, provider, _) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Water Capacity (L)",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        HomeManualField(
                                          hint: "Water Capacity (L)",
                                          keyboardType: TextInputType.number,
                                          controller: capacityController,
                                          validator: (v) =>
                                              (v == null || v.isEmpty)
                                              ? ""
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isCylinderExpired) ...[
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Working Pressure",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: theme
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          HomeValueBox(
                                            text:
                                                provider
                                                    .state
                                                    .selectedProduct
                                                    ?.workingPressure ??
                                                "204.00",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (!isCylinderExpired) ...[
                                const SizedBox(height: 15),
                                const HomeRowLabels(
                                  l1: "Test Pressure",
                                  l2: "Initial Expansion",
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: HomeValueBox(
                                        text:
                                            provider
                                                .state
                                                .selectedProduct
                                                ?.testingPressure ??
                                            "340.00",
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: HomeManualField(
                                        hint: "Initial Expansion",
                                        controller: expansionInitialController,
                                        validator: (v) =>
                                            (v == null || v.isEmpty)
                                            ? ""
                                            : null,
                                        keyboardType: TextInputType.number,
                                        onChanged: (_) => _calculateExpansion(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                const HomeRowLabels(
                                  l1: "Total Expansion",
                                  l2: "Permanent Expansion",
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: HomeManualField(
                                        hint: "Total Expansion",
                                        controller: expansionTotalController,
                                        validator: (v) =>
                                            (v == null || v.isEmpty)
                                            ? ""
                                            : null,
                                        keyboardType: TextInputType.number,
                                        onChanged: (_) => _calculateExpansion(),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: HomeManualField(
                                        hint: "Permanent Expansion",
                                        controller: expansionPermController,
                                        validator: (v) =>
                                            (v == null || v.isEmpty)
                                            ? ""
                                            : null,
                                        keyboardType: TextInputType.number,
                                        onChanged: (_) => _calculateExpansion(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                const HomeRowLabels(
                                  l1: "Permanent Exp (%)",
                                  l2: "Result",
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          HomeValueBox(
                                            text:
                                                expansionPctController
                                                    .text
                                                    .isEmpty
                                                ? "0.00%"
                                                : "${expansionPctController.text}%",
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: HomeDropDownField(
                                        hint: selectedResult ?? "PASS",
                                        items: const ["PASS", "FAIL"],
                                        validator: (v) =>
                                            (selectedResult == null)
                                            ? ""
                                            : null,
                                        onChanged: (v) =>
                                            setState(() => selectedResult = v),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                    Consumer<HomeProvider>(
                      builder: (context, provider, _) {
                        if (!provider.state.photoRequired)
                          return const SizedBox.shrink();
                        return Column(
                          children: [
                            const HomeSectionHeader(title: "Photo Uploads"),
                            ActionCardNoTitle(
                              child: Column(
                                children: [
                                  if (!isCylinderExpired) ...[
                                    DashedUploadArea(
                                      title: "Capture Photo of Number Plate",
                                      onPick: () =>
                                          _pickAndCompressImage("plate"),
                                      imagePath: pickedImages["plate"],
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                  DashedUploadArea(
                                    title: "Capture Photo of Cylinder Marking",
                                    onPick: () => _pickAndCompressImage("neck"),
                                    imagePath: pickedImages["neck"],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    if (isRemarkRequired) ...[
                      const HomeSectionHeader(title: "Remarks"),
                      ActionCardNoTitle(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Remarks",
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                            const SizedBox(height: 8),
                            HomeManualField(
                              hint: "Remarks",
                              controller: remarksController,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return isVehicleWarning
                                      ? "Remark is required for this vehicle."
                                      : "As you are performing an early test, please specify the reason in the Remarks field.";
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
                      builder: (context, provider, _) {
                        return CustomButton(
                          text: isCylinderExpired
                              ? "Submit Rejected Certificate"
                              : "Submit Certificate",
                          isLoading:
                              provider.state.certificateStatus ==
                              HomeStatus.loading,
                          onPressed: () {
                            _submitCertificate();
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

  void _submitCertificate() async {
    final provider = context.read<HomeProvider>();
    final authRepo = context.read<AuthRepository>();
    if (selectedVehicleType == null) {
      _showError("Please select Vehicle Type");
      return;
    }
    if (provider.state.photoRequired) {
      if (!isCylinderExpired) {
        if (pickedImages["plate"] == null) {
          _showError("Please capture Number Plate photo");
          return;
        }
      }
      if (pickedImages["neck"] == null) {
        _showError("Please capture Cylinder Marking photo");
        return;
      }
    }
    final userId = await authRepo.getUserId();
    final adminId = await authRepo.getAdminId();
    final data = {
      'adminid': adminId ?? '',
      'license_name': 'PREMIUM HYDRO ENGINEERING',
      'approval_no': 'AG/HQ/GJ/GCT/1G49051',
      'vehicle_type': '${selectedVehicleTypeId ?? ''}',
      'vehicle_number': '${vehicleNumberController.text}',
      'vehicle_format': '${selectedVehicleFormat ?? ''}',
      'cascade_no': cascadeNoController.text,
      'test_date': '${testDate ?? ''}',
      'collection_date': '${testDate ?? ''}',
      'next_test_date': '${nextTestDate ?? ''}',
      'product_type':
          context.read<HomeProvider>().state.selectedProduct?.fullname ??
          'Compress Natural Gas',
      'specification':
          context.read<HomeProvider>().state.selectedCylinderType ??
          context.read<HomeProvider>().state.selectedProduct?.standard ??
          'IS 15490',
      'cylinder_serial_no': '${serialNoController.text}',
      'last_test_date': '${lastTestingDate ?? ''}',
      'cylinder_make': '${selectedCylinderMakeId ?? ''}',
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
        int mIdx = mNames.indexOf(manufacturingMonthController.text);
        String mm = (mIdx != -1) ? (mIdx + 1).toString().padLeft(2, '0') : '01';
        return '$mm-${manufacturingYearController.text}';
      }(),
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
      'working_pressure':
          provider.state.selectedProduct?.workingPressure ?? '204',
      'test_pressure': provider.state.selectedProduct?.testingPressure ?? '340',
      'initial_expansion': expansionInitialController.text,
      'total_expansion': expansionTotalController.text,
      'permanent_expansion': expansionPermController.text,
      'permanent_expansion_percentage': expansionPctController.text,
      'result': selectedResult ?? 'PASS',
      'remark': remarksController.text,
      if (provider.state.isRetailCustomer)
        'retail_amount': amountController.text
      else
        'amount': provider.state.productAmount ?? '',
      'retail_customer': provider.state.isRetailCustomer ? '001' : '',
      'is_multi_cylinder': isMultiCylinder?.toString() ?? '',
      'early_testing_reason': earlyTestingReason ?? '',
      'userid': userId ?? '',
      'dealer_name': provider.state.isRetailCustomer
          ? 'rc01'
          : (selectedDealerId?.toString() ?? ''),
      'mobile_no': mobileNumberController.text,
      if (provider.state.isRetailCustomer)
        'retail_cust_name': retailCustNameController.text,
      'status': '2',
      'upload_type': 'insert',
      'photo_path_plate': pickedImages['plate'],
      'photo_path_neck': pickedImages['neck'],
    };
    if (mounted) {
      bool success;
      if (isCylinderExpired) {
        final rejectedData = {
          'vehicle_number': (data['vehicle_number'] as String).trim(),
          'license_name': (data['license_name'] as String).trim(),
          'approval_no': (data['approval_no'] as String).trim(),
          'vehicle_type': (data['vehicle_type'] as String).trim(),
          'vehicle_format': (data['vehicle_format'] as String).trim(),
          'test_date': (data['test_date'] as String).trim(),
          'next_test_date': (data['next_test_date'] as String).trim(),
          'product_type': (data['product_type'] as String).trim(),
          'specification': (data['specification'] as String).trim(),
          'manufacturing_date': (data['manufacturing_date'] as String).trim(),
          'cascade_no': cascadeNoController.text,
          'cylinder_no': (data['cylinder_serial_no'] as String).trim(),
          'cylinder_make': (data['cylinder_make'] as String).trim(),
          'cce_filling_permission_no':
              (data['cce_filling_permission_no'] as String).trim(),
          'filling_permission_date': (data['filling_permission_date'] as String)
              .trim(),
          'expire_date': (data['expire_date'] as String).trim(),
          'last_test_date': (data['last_test_date'] as String).trim(),
          'rejected_water_capacity': (data['water_capacity'] as String).trim(),
          'admin_id': (data['adminid'] as String).trim(),
          'user_id': (data['userid'] as String).trim(),
          'rcp': pickedImages['neck'],
          if (provider.state.isRetailCustomer)
            'retail_amount': data['retail_amount']
          else
            'amount': data['amount'],
          'dealer_name': provider.state.isRetailCustomer
              ? 'rc01'
              : data['dealer_name'],
          'mobile_no': data['mobile_no'],
          if (provider.state.isRetailCustomer)
            'retail_cust_name': data['retail_cust_name'],
        };
        success = await provider.submitRejectedCylinder(rejectedData, context);
      } else {
        success = await provider.submitRole2Certificate(data, context);
      }
      if (success && mounted) {
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
                    Text(
                      isCylinderExpired
                          ? "Rejected cylinder recorded successfully."
                          : "Certificate created successfully.",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
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
                          if (isCylinderExpired) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const HomeScreen(role: "role_2"),
                              ),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const Role2CertificateListScreen(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
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
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Widget _buildVehicleTypeDropdown({String? Function(String?)? validator}) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final types =
            provider.state.vehicleTypeData?.data
                ?.map((e) => e.vehicleName ?? "")
                .toList() ??
            [];
        return HomeDropDownField(
          hint: selectedVehicleType ?? "Choose Vehicle Type",
          items: types,
          validator: validator,
          onChanged: (v) {
            final vehicleTypes = provider.state.vehicleTypeData?.data ?? [];
            try {
              final selected = vehicleTypes.firstWhere(
                (e) => e.vehicleName == v,
              );
              setState(() {
                selectedVehicleType = v;
                selectedVehicleTypeId = selected.id;
              });
              provider.clearProductAmount();
              final dId = provider.state.isRetailCustomer
                  ? '0'
                  : selectedDealerId?.toString();
              if (selected.id != null && dId != null)
                provider.getProductAmountByDealer({
                  'dealer_id': dId,
                  'vehicle_id': selected.id.toString(),
                  'product_id':
                      provider.state.selectedProduct?.id?.toString() ?? '',
                });
            } catch (_) {
              setState(() {
                selectedVehicleType = v;
                selectedVehicleTypeId = null;
              });
              provider.clearProductAmount();
            }
          },
        );
      },
    );
  }

  Widget _buildVehicleFormatDropdown({String? Function(String?)? validator}) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final formats =
            provider.state.vehicleFormatData?.data
                ?.map((e) => e.vFormat ?? "")
                .toList() ??
            [];
        return HomeDropDownField(
          hint: selectedVehicleFormat ?? "CHOOSE VEHICLE FOR",
          items: formats,
          validator: validator,
          onChanged: (v) => setState(() => selectedVehicleFormat = v),
        );
      },
    );
  }

  Widget _buildDealerAndMobileSection() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final isRetail = provider.state.isRetailCustomer;
        final dealerList = provider.state.dealerTypeData?.data ?? [];
        final dealers = [
          "Retail Customer",
          ...dealerList.map((e) => e.fullname ?? ""),
        ];
        return Column(
          children: [
            HomeRowLabels(
              l1: "Choose Dealer",
              l2: isRetail ? "Retail Customer Name" : "Mobile Number",
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: HomeDropDownField(
                    hint: selectedDealer ?? "Choose Dealer",
                    items: dealers,
                    onChanged: (val) {
                      if (val == null || val == "Retail Customer") {
                        provider.setIsRetailCustomer(val == "Retail Customer");
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
                      final selected = dealerList.firstWhere(
                        (e) => e.fullname == val,
                      );
                      final retail = val.toLowerCase().contains('retail');
                      provider.setIsRetailCustomer(retail);
                      setState(() {
                        selectedDealer = val;
                        selectedDealerId = selected.id;
                        if (!retail)
                          mobileNumberController.text = selected.mobileNo ?? '';
                      });
                      if (retail) {
                        provider.clearDealerAmount();
                        provider.clearProductAmount();
                        provider.getVehicleType('rc01');
                      } else if (selected.id != null) {
                        provider.getVehicleType(selected.id.toString());
                        provider.getProductAmountByDealer({
                          'dealer_id': selected.id.toString(),
                          'vehicle_id': selectedVehicleTypeId?.toString() ?? '',
                          'product_id':
                              provider.state.selectedProduct?.id?.toString() ??
                              '',
                        });
                        provider.getDealerAmount(selected.id.toString());
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return "Enter Mobile No";
                        if (val.length != 10) return "Must be 10 digits";
                        return null;
                      },
                    ),
                  )
                else
                  Expanded(
                    child: HomeManualField(
                      hint: "Enter Customer Name",
                      controller: retailCustNameController,
                      validator: (val) {
                        if (isRetail && (val == null || val.isEmpty))
                          return "Required";
                        return null;
                      },
                    ),
                  ),
              ],
            ),
            if (isRetail) ...[
              const SizedBox(height: 15),
              const HomeRowLabels(l1: "Enter Amount", l2: "Enter Mobile No."),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: HomeManualField(
                      hint: "Enter Amount",
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) {
                        if (isRetail && (val == null || val.isEmpty))
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Required";
                        if (val.length != 10) return "Must be 10 digits";
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
    );
  }

  Widget _buildProductAmountDisplay() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (provider.state.productAmountStatus == HomeStatus.success &&
            provider.state.productAmount != null &&
            selectedVehicleTypeId != null) {
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
              if (provider.state.totalDuesPending != null) ...[
                const SizedBox(height: 4),
                Text(
                  "Total Dues Pending:₹ ${provider.state.totalDuesPending}",
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
    );
  }

  Widget _buildCylinderMakeDropdown({String? Function(String?)? validator}) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final data = provider.state.cylinderMakeData?.data ?? [];
        final items = data.map((e) => e.fullname ?? "").toList();
        return HomeDropDownField(
          hint: selectedCylinderMakeName ?? "Select Cylinder Mk",
          items: items,
          validator: validator,
          onChanged: (v) {
            final selected = data.firstWhere((e) => e.fullname == v);
            setState(() {
              selectedCylinderMakeName = v;
              selectedCylinderMakeId = selected.id?.toString();
            });
          },
        );
      },
    );
  }

  Widget _buildDatePicker(
    String label,
    String? current,
    void Function(String?) onPicked, {
    String? Function(String?)? validator,
  }) {
    return HomeDatePickerField(
      label: label,
      displayDate: current,
      validator: validator,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (date != null)
          onPicked(
            "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}",
          );
      },
    );
  }

  Widget _buildProductDetailsRow() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final product = provider.state.selectedProduct;
        return Row(
          children: [
            Expanded(
              child: HomeValueBox(text: product?.fullname ?? "Loading..."),
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
        );
      },
    );
  }

  Widget _buildInspectionRow(
    String l1,
    String l2,
    String? s1,
    String? s2,
    TextEditingController c1,
    TextEditingController c2,
    void Function(String?) onS1,
    void Function(String?) onS2,
  ) {
    return Column(
      children: [
        HomeRowLabels(l1: l1, l2: l2),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: HomeDropDownField(
                hint: s1 ?? "OK",
                items: const ["OK", "Not OK"],
                validator: (v) => (s1 == null) ? "" : null,
                onChanged: onS1,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: HomeDropDownField(
                hint: s2 ?? "OK",
                items: const ["OK", "Not OK"],
                validator: (v) => (s2 == null) ? "" : null,
                onChanged: onS2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const HomeRowLabels(l1: "Observation/Remark", l2: "Observation/Remark"),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: HomeManualField(
                hint: "Observation/Remark",
                controller: c1,
                validator: (v) => (v == null || v.isEmpty) ? "" : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: HomeManualField(
                hint: "Observation/Remark",
                controller: c2,
                validator: (v) => (v == null || v.isEmpty) ? "" : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
      ],
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
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.2 : 0.03,
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

class ActionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const ActionCard({super.key, required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.2 : 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(width: 3, height: 18, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(15), child: child),
        ],
      ),
    );
  }
}
