import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:premium_engneering_app/features/auth/data/auth_repository.dart';
import 'package:premium_engneering_app/features/home/provider/home_provider.dart';
import 'package:premium_engneering_app/features/home/provider/home_state.dart';
import '../../../core/theme.dart';
import '../../../widgets/custom_widgets.dart';
import '../widgets/home_components.dart';
import 'role1_certificate_list_screen.dart';
import 'role2_certificate_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final String role;
  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? role;
  String? userName;

  final ImagePicker _picker = ImagePicker();
  Map<String, String?> pickedImages = {};
  Map<String, String?> pickedDates = {};
  String? selectedGasId;
  String? selectedGasName;
  String? selectedCylinderType;
  String? selectedVehicleType;
  final TextEditingController _vehicleNumberController =
      TextEditingController();
  final TextEditingController _visualRemarkController = TextEditingController();
  final TextEditingController _valveRemarkController = TextEditingController();
  final TextEditingController _tareWeightController = TextEditingController();
  final TextEditingController _actualWeightController = TextEditingController();
  final TextEditingController _shellThicknessController =
      TextEditingController();
  final TextEditingController _observedThicknessController =
      TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  List<String> standardNames = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeProvider>().loadHomeData();
      context.read<HomeProvider>().addListener(_onHomeStateChanged);
    });
    _fetchRole();
  }

  Future<void> _fetchRole() async {
    final authRepo = context.read<AuthRepository>();
    final fetchedRole = await authRepo.getUserType();
    final fetchedName = await authRepo.getUserName();
    if (mounted) {
      setState(() {
        role = fetchedRole;
        userName = fetchedName;
      });
    }
    print('--------------------------role--------->${role}');
    print('--------------------------userName----->${userName}');
  }

  @override
  void dispose() {
    context.read<HomeProvider>().removeListener(_onHomeStateChanged);
    super.dispose();
  }

  void _onHomeStateChanged() {
    // Certificate status feedback is shown directly in home_provider submit methods
  }

  void _submitCertificate() async {
    final Map<String, dynamic> data = {
      "gas_name": selectedGasId,
      "cylinder_type": selectedCylinderType,
      "vehicle_type": selectedVehicleType,
      "vehicle_number": _vehicleNumberController.text,
      "test_date": pickedDates["Test Date"],
    };

    // Add images as MultipartFiles
    for (var entry in pickedImages.entries) {
      if (entry.value != null) {
        data[entry.key] = await MultipartFile.fromFile(entry.value!);
      }
    }

    if ((role ?? widget.role).toLowerCase().contains("role_2")) {
      data.addAll({
        "visual_remark": _visualRemarkController.text,
        "valve_remark": _valveRemarkController.text,
        "tare_weight": _tareWeightController.text,
        "actual_weight": _actualWeightController.text,
        "shell_thickness": _shellThicknessController.text,
        "observed_thickness": _observedThicknessController.text,
        "remarks": _remarksController.text,
      });
    }

    context.read<HomeProvider>().createCertificate(data, context);
  }

  Future<void> _pickImage(String tag) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSelectionBottomSheet(tag),
    );
  }

  Widget _buildSelectionBottomSheet(String tag) {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Upload Photo",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textTitle,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Choose an option to upload your file",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: _buildImageSourceOption(
                    title: "Camera",
                    subtitle: "Take a new photo",
                    icon: Icons.camera_enhance_rounded,
                    color: Colors.teal,
                    delay: 100,
                    onTap: () => _handleImageSelection(ImageSource.camera, tag),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildImageSourceOption(
                    title: "Gallery",
                    subtitle: "Choose from device",
                    icon: Icons.photo_library_rounded,
                    color: Colors.indigo,
                    delay: 200,
                    onTap: () =>
                        _handleImageSelection(ImageSource.gallery, tag),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImageSelection(ImageSource source, String tag) async {
    Navigator.pop(context); // Close bottom sheet
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() => pickedImages[tag] = image.path);
    }
  }

  Widget _buildImageSourceOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int delay,
    required VoidCallback onTap,
  }) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, String tag) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      helpText: "Select $tag",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textTitle,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        pickedDates[tag] =
            "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(context: context, builder: (context) => const LogoutDialog());
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header matching production
          _buildHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (_currentIndex == 0) ...[_buildCreateCertificateCard()],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            final userRole = (role ?? widget.role).toLowerCase();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => userRole.contains("2")
                    ? const Role2CertificateListScreen()
                    : const Role1CertificateListScreen(),
              ),
            );
          } else if (index == 2) {
            _showLogoutDialog();
          } else {
            setState(() => _currentIndex = index);
          }
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.group_add_rounded),
            label: "New Certificate",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted_rounded),
            label: "Certificate List",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout_rounded),
            label: "Logout",
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome :",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Text(
                        userName ?? role ?? '',
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
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCreateCertificateCard() {
    return Column(
      children: [
        const SizedBox(height: 50),
        const Text(
          "Enter New Certificate",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textTitle,
          ),
        ),
        const SizedBox(height: 30),
        ActionCard(
          title: "Select Product",
          child: Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              final state = homeProvider.state;
              if (state.status == HomeStatus.loading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (state.status == HomeStatus.error) {
                return Center(
                  child: Column(
                    children: [
                      Text(
                        "Error: ${state.errorMessage}",
                        style: const TextStyle(color: Colors.red),
                      ),
                      TextButton(
                        onPressed: () => homeProvider.loadHomeData(),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              } else if (state.status == HomeStatus.success) {
                final products = state.homeData?.data ?? [];
                return Column(
                  children: [
                    const HomeRowLabels(
                      l1: "Select Gas Name",
                      l2: "Cyl Specification",
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: HomeDropDownField(
                            hint: selectedGasName ?? "Select Gas",
                            items: products
                                .map((p) => p.fullname ?? "")
                                .toList(),
                            onChanged: (val) async {
                              final product = products.firstWhere(
                                (p) => p.fullname == val,
                                orElse: () => products.first,
                              );
                              setState(() {
                                selectedGasName = val;
                                selectedGasId = product.id.toString();
                                selectedCylinderType = product.standard;
                                standardNames = [];
                              });
                              homeProvider.setSelectedProduct(product);
                              homeProvider.setSelectedCylinderType(
                                product.standard,
                              );

                              final isCNG =
                                  val!.toLowerCase().contains('cng') ||
                                  (val.toLowerCase().contains('compress') &&
                                      val.toLowerCase().contains('natural') &&
                                      val.toLowerCase().contains('gas'));

                              if (isCNG) {
                                // Show loader
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final standards = await homeProvider
                                  .getProductStandardName(
                                    product.id.toString(),
                                  );

                              if (mounted) {
                                if (isCNG) {
                                  Navigator.pop(
                                    context,
                                  ); // Close loading dialog
                                }
                                if (standards.isNotEmpty) {
                                  setState(() {
                                    standardNames = standards;
                                    selectedCylinderType = standards.first;
                                  });
                                  homeProvider.setSelectedCylinderType(
                                    standards.first,
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: standardNames.isEmpty
                              ? HomeValueBox(text: selectedCylinderType ?? "")
                              : HomeDropDownField(
                                  hint: selectedCylinderType ?? "Select Spec",
                                  items: standardNames,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedCylinderType = val;
                                    });
                                    homeProvider.setSelectedCylinderType(val);
                                  },
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    state.certificateStatus == HomeStatus.loading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: "Create New Certificate",
                            onPressed: () async {
                              if (selectedGasId == null) {
                                CustomToast.error(
                                  context,
                                  "Please select gas name",
                                );
                                return;
                              }
                              if (selectedCylinderType == null) {
                                CustomToast.error(
                                  context,
                                  "Please select cylinder type",
                                );
                                return;
                              }

                              final adminId = await homeProvider.authRepository
                                  .getAdminId();
                              await homeProvider.createCertificate({
                                'gas_id': selectedGasId,
                                'admin_id': adminId,
                              }, context);

                              if (mounted) {
                                setState(() {
                                  selectedGasId = null;
                                  selectedGasName = null;
                                  selectedCylinderType = null;
                                  standardNames = [];
                                });
                                homeProvider.clearSelectedProductAndType();
                              }
                            },
                          ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropDownField(
    String hint,
    List<String> items,
    void Function(String?)? onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(fontSize: 12)),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textTitle,
        ),
      ),
    );
  }

  Widget _buildRowLabels(String l1, String l2) {
    return Row(
      children: [
        Expanded(
          child: Text(
            l1,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            l2,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildValueBox(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildManualField(
    String hint, {
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
          hintStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(String label) {
    String displayDate = pickedDates[label] ?? label;
    bool isPicked = pickedDates[label] != null;
    return GestureDetector(
      onTap: () => _selectDate(context, label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.fieldFill,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              displayDate,
              style: TextStyle(
                fontSize: 13,
                color: isPicked ? Colors.black87 : Colors.grey,
                fontWeight: isPicked ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Icon(
              Icons.calendar_month,
              size: 20,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
