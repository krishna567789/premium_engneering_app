// import 'dart:io';
// import 'package:animate_do/animate_do.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../home/screens/role1_screen.dart';
// import 'package:premium_engneering_app/features/home/provider/home_state.dart';
// import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import '../../../core/theme.dart';
// import '../../../widgets/custom_widgets.dart';
// import '../../home/provider/home_provider.dart';
// import '../../home/model/role1_certificate_list_model.dart';
// import '../../home/screens/licence_detail.dart';
// import '../../auth/data/auth_repository.dart';

// class EditCertificateScreen extends StatefulWidget {
//   final CertificateData certificate;
//   final String role;
//   const EditCertificateScreen({
//     super.key,
//     required this.certificate,
//     required this.role,
//   });

//   @override
//   State<EditCertificateScreen> createState() => _EditCertificateScreenState();
// }

// class _EditCertificateScreenState extends State<EditCertificateScreen> {
//   final _formKey = GlobalKey<FormState>();

//   late TextEditingController vehicleNumberController;
//   late TextEditingController mobileNumberController;
//   late TextEditingController manufacturingMonthController;
//   late TextEditingController manufacturingYearController;
//   late TextEditingController expiryYearController;

//   // Role 2 expansion controllers
//   late TextEditingController expansionInitialController;
//   late TextEditingController expansionTotalController;
//   late TextEditingController expansionPermController;
//   late TextEditingController expansionPctController;
//   late TextEditingController capacityController;
//   late TextEditingController cceNoController;
//   String? selectedResult;

//   String? selectedVehicleType;
//   int? selectedVehicleTypeId;
//   String? selectedVehicleFormat;
//   String? selectedDealer;
//   int? selectedDealerId;
//   String? selectedCylinderMakeName;
//   String? selectedCylinderMakeId;
//   String? collectionDate;
//   String? testDate;
//   String? nextTestDate;
//   String? fillingPermDate;
//   String? lastTestingDate;
//   String? weightErrorMessage;
//   bool isCylinderExpired = false;

//   // Testing Details Controllers
//   late TextEditingController initialObsController;
//   late TextEditingController visualObsController;
//   late TextEditingController threadingObsController;
//   late TextEditingController internalObsController;
//   late TextEditingController tareWeightController;
//   late TextEditingController actualWeightController;
//   late TextEditingController weightLossKgController;
//   late TextEditingController weightLossPctController;
//   late TextEditingController cylinderSizeController;

//   late TextEditingController shellMinController;
//   late TextEditingController shellObsController;
//   late TextEditingController bottomMinController;
//   late TextEditingController bottomObsController;
//   late TextEditingController remarksController;
//   late TextEditingController serialNoController;

//   // Inspections Status
//   String? initialStatus;
//   String? visualStatus;
//   String? threadingStatus;
//   String? internalStatus;
//   String? plateStatus;

//   Map<String, String?> pickedImages = {"plate": null, "neck": null};

//   @override
//   void initState() {
//     super.initState();
//     final cert = widget.certificate;

//     // 🔹 Initialize controllers with existing data
//     vehicleNumberController = TextEditingController(text: cert.vehicleNumber);
//     mobileNumberController = TextEditingController(text: cert.mobile ?? "");
//     expiryYearController = TextEditingController(text: cert.expireDate);

//     // expansion
//     capacityController = TextEditingController(text: cert.waterCapacity);
//     expansionInitialController = TextEditingController(
//       text: cert.initialExpansion,
//     );
//     expansionTotalController = TextEditingController(text: cert.totalExpansion);
//     expansionPermController = TextEditingController(
//       text: cert.permanentExpansion,
//     );
//     expansionPctController = TextEditingController(
//       text: cert.permanentExpansionPercentage,
//     );
//     cceNoController = TextEditingController(text: cert.cceFillingPermissionNo);
//     selectedResult = cert.result ?? "PASS";

//     // Testing Details
//     initialObsController = TextEditingController(
//       text: cert.valveInspectionRemark,
//     );
//     visualObsController = TextEditingController(
//       text: cert.visualInspectionRemark,
//     );
//     threadingObsController = TextEditingController(
//       text: cert.cylinderThreadingRemark,
//     );
//     internalObsController = TextEditingController(
//       text: cert.internalInspectionRemark,
//     );
//     tareWeightController = TextEditingController(text: cert.originalTareWeight);
//     actualWeightController = TextEditingController(text: cert.actualWeight);
//     weightLossKgController = TextEditingController(text: cert.lossOfWeight);
//     weightLossPctController = TextEditingController(
//       text: cert.lossOfWeightPercentage,
//     );
//     cylinderSizeController = TextEditingController(text: cert.dieOfCylinder);

//     shellMinController = TextEditingController(text: cert.shellMinCalThick);
//     shellObsController = TextEditingController(text: cert.shellObsThickMin);
//     bottomMinController = TextEditingController(text: cert.bottomMinCalThick);
//     bottomObsController = TextEditingController(text: cert.bottomObsThickMin);
//     remarksController = TextEditingController(text: cert.remark);
//     serialNoController = TextEditingController(text: cert.cylinderSerialNo);

//     // Initial Statuses
//     initialStatus = cert.valveInspection == "0" ? "OK" : "Not OK";
//     visualStatus = cert.visualInspection == "0" ? "OK" : "Not OK";
//     threadingStatus = cert.cylinderThreading == "0" ? "OK" : "Not OK";
//     internalStatus = cert.internalInspection == "0" ? "OK" : "Not OK";
//     plateStatus = "OK"; // Default or parse if exists

//     // Split manufacturing date "2020-04"
//     if (cert.manufacturingDate != null &&
//         cert.manufacturingDate!.contains("-")) {
//       final parts = cert.manufacturingDate!.split("-");
//       if (parts[0].length == 4) {
//         // YYYY-MM
//         manufacturingMonthController = TextEditingController(text: parts[1]);
//         manufacturingYearController = TextEditingController(text: parts[0]);
//       } else {
//         // MM-YYYY
//         manufacturingMonthController = TextEditingController(text: parts[0]);
//         manufacturingYearController = TextEditingController(text: parts[1]);
//       }
//     } else {
//       manufacturingMonthController = TextEditingController();
//       manufacturingYearController = TextEditingController();
//     }

//     // 🔹 Initialize selections
//     selectedVehicleType = cert.vehicalType;
//     selectedVehicleFormat = cert.vehicleFormat;
//     fillingPermDate = cert.fillingPermissionDate;
//     lastTestingDate = cert.lastTestDate;
//     selectedCylinderMakeName = cert.cylinderMake;
//     selectedDealer = cert.dealerName;
//     selectedDealerId = cert.dealerId;

//     // Fetch data for dropdowns
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = context.read<HomeProvider>();
//       provider.getVehicleType();
//       provider.getVehicleFormat();
//       provider.getDealerType();
//       provider.getCylinderMake();
//     });

//     // Parse testDate and nextTestDate (Role 2)
//     testDate = cert.testDate != null && cert.testDate!.contains("-")
//         ? cert.testDate
//         : null;
//     nextTestDate = cert.nextTestDate != null && cert.nextTestDate!.contains("-")
//         ? cert.nextTestDate
//         : null;

//     // Parse collectionDate if it's in YYYY-MM-DD format
//     if (cert.collectionDate != null &&
//         cert.collectionDate!.contains("-") &&
//         !cert.collectionDate!.startsWith("00")) {
//       final parts = cert.collectionDate!.split("-");
//       if (parts[0].length == 4) {
//         // YYYY-MM-DD to DD-MM-YYYY
//         collectionDate = "${parts[2]}-${parts[1]}-${parts[0]}";
//       } else {
//         collectionDate = cert.collectionDate;
//       }
//     } else {
//       collectionDate = null;
//     }

//     // Parse Role 2 dates (Convert YYYY-MM-DD to DD-MM-YYYY)
//     if (widget.role.toLowerCase().contains("2")) {
//       if (cert.testDate != null && cert.testDate!.contains("-")) {
//         final p = cert.testDate!.split("-");
//         testDate = p[0].length == 4 ? "${p[2]}-${p[1]}-${p[0]}" : cert.testDate;
//       }
//       if (cert.nextTestDate != null && cert.nextTestDate!.contains("-")) {
//         final p = cert.nextTestDate!.split("-");
//         nextTestDate = p[0].length == 4
//             ? "${p[2]}-${p[1]}-${p[0]}"
//             : cert.nextTestDate;
//       }
//       if (cert.lastTestDate != null && cert.lastTestDate!.contains("-")) {
//         final p = cert.lastTestDate!.split("-");
//         lastTestingDate = p[0].length == 4
//             ? "${p[2]}-${p[1]}-${p[0]}"
//             : cert.lastTestDate;
//       }
//       if (cert.fillingPermissionDate != null &&
//           cert.fillingPermissionDate!.contains("-")) {
//         final p = cert.fillingPermissionDate!.split("-");
//         fillingPermDate = p[0].length == 4
//             ? "${p[2]}-${p[1]}-${p[0]}"
//             : cert.fillingPermissionDate;
//       }
//     }

//     // Fetch dependencies
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = context.read<HomeProvider>();
//       provider.getVehicleType();
//       provider.getDealerType();
//       provider.getVehicleFormat();
//       provider.loadHomeData();
//     });
//   }

//   @override
//   void dispose() {
//     vehicleNumberController.dispose();
//     mobileNumberController.dispose();
//     manufacturingMonthController.dispose();
//     manufacturingYearController.dispose();
//     cceNoController.dispose();
//     expiryYearController.dispose();
//     super.dispose();
//   }

//   void _syncExpiryDate() {
//     final year = int.tryParse(manufacturingYearController.text);
//     if (year != null && manufacturingMonthController.text.isNotEmpty) {
//       final List<String> monthNames = [
//         "January",
//         "February",
//         "March",
//         "April",
//         "May",
//         "June",
//         "July",
//         "August",
//         "September",
//         "October",
//         "November",
//         "December",
//       ];
//       int monthIndex = monthNames.indexOf(manufacturingMonthController.text);
//       if (monthIndex != -1) {
//         final provider = context.read<HomeProvider>();
//         final lifeYears =
//             provider.state.homeData?.data?.firstOrNull?.lifeOfCylinder ?? 20;
//         int expiryYearValue = year + lifeYears;
//         String month = (monthIndex + 1).toString().padLeft(2, '0');

//         // 🔹 Check expiration
//         DateTime now = DateTime.now();
//         bool expired = false;
//         if (expiryYearValue < now.year) {
//           expired = true;
//         } else if (expiryYearValue == now.year) {
//           if ((monthIndex + 1) < now.month) {
//             expired = true;
//           }
//         }

//         setState(() {
//           expiryYearController.text = "$expiryYearValue-$month-01";
//           isCylinderExpired = expired;
//         });
//       }
//     }
//   }

//   void _syncFillingPermDate() {
//     if (manufacturingMonthController.text.isNotEmpty &&
//         manufacturingYearController.text.isNotEmpty) {
//       final List<String> monthNames = [
//         "January",
//         "February",
//         "March",
//         "April",
//         "May",
//         "June",
//         "July",
//         "August",
//         "September",
//         "October",
//         "November",
//         "December",
//       ];
//       int monthIndex = monthNames.indexOf(manufacturingMonthController.text);
//       if (monthIndex != -1) {
//         String month = (monthIndex + 1).toString().padLeft(2, '0');
//         String year = manufacturingYearController.text;
//         setState(() {
//           fillingPermDate = "$year-$month-01";
//         });
//       }
//     }
//   }

//   void _calculateWeightLoss() {
//     double original = double.tryParse(tareWeightController.text) ?? 0.0;
//     double actual = double.tryParse(actualWeightController.text) ?? 0.0;

//     if (original > 0 && actual > 0) {
//       double loss = original - actual;
//       double lossPct = (loss / original) * 100;

//       setState(() {
//         weightLossKgController.text = loss.toStringAsFixed(3);
//         weightLossPctController.text = lossPct.toStringAsFixed(2);

//         if (lossPct > 5.0) {
//           weightErrorMessage =
//               "Cylinder Rejected: Weight loss exceeds 5% ($lossPct%)";
//         } else {
//           weightErrorMessage = null;
//         }
//       });
//     }
//   }

//   Future<void> _pickAndCompressImage(String tag) async {
//     final ImagePicker picker = ImagePicker();
//     final source = await showModalBottomSheet<ImageSource>(
//       context: context,
//       builder: (context) => SafeArea(
//         child: Wrap(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text('Camera'),
//               onTap: () => Navigator.pop(context, ImageSource.camera),
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('Gallery'),
//               onTap: () => Navigator.pop(context, ImageSource.gallery),
//             ),
//           ],
//         ),
//       ),
//     );

//     if (source == null) return;

//     final XFile? image = await picker.pickImage(source: source);
//     if (image == null) return;

//     final String targetPath =
//         "${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

//     XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
//       image.path,
//       targetPath,
//       quality: 60,
//       minWidth: 1024,
//       minHeight: 1024,
//     );

//     if (compressedFile != null) {
//       setState(() {
//         pickedImages[tag] = compressedFile.path;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     String? formatDisplayDate(String? dateStr) {
//       if (dateStr == null || dateStr.isEmpty || !dateStr.contains("-")) {
//         return dateStr;
//       }
//       final parts = dateStr.split("-");
//       if (parts.length == 3 && parts[0].length == 4) {
//         // YYYY-MM-DD to DD-MM-YYYY
//         return "${parts[2]}-${parts[1]}-${parts[0]}";
//       }
//       return dateStr;
//     }

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: const Text(
//           "Update Certificate",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: AppColors.primary,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         actions: [
//           IconButton(
//             onPressed: () => Navigator.pop(context),
//             icon: const Icon(Icons.close),
//           ),
//         ],
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 15),
//           child: Column(
//             children: [
//               const SizedBox(height: 20),

//               /// 🔹 License Details
//               _buildSectionHeader("License Details"),
//               _buildActionCard(
//                 child: Column(
//                   children: [
//                     const _RowLabels(l1: "License Name", l2: "Approval No"),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _ValueBox(
//                             text: widget.certificate.licenseName ?? "N/A",
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: _ValueBox(
//                             text: widget.certificate.approvalNo ?? "N/A",
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               /// 🔹 Vehicle Details
//               _buildSectionHeader("Vehicle Details"),
//               _buildActionCard(
//                 child: Column(
//                   children: [
//                     _RowLabels(
//                       l1: "Vehicle Type",
//                       l2: widget.role.toLowerCase().contains("2")
//                           ? "Test Date"
//                           : "Collection Date",
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Consumer<HomeProvider>(
//                             builder: (context, provider, _) {
//                               final vehicleTypes =
//                                   provider.state.vehicleTypeData?.data ?? [];
//                               final types = vehicleTypes
//                                   .map((e) => e.vehicleName ?? "")
//                                   .toList();

//                               String displayValue =
//                                   selectedVehicleType ?? "Select Type";
//                               try {
//                                 final match = vehicleTypes.firstWhere(
//                                   (e) =>
//                                       e.id.toString() == displayValue ||
//                                       e.vehicleName == displayValue,
//                                 );
//                                 displayValue =
//                                     match.vehicleName ?? displayValue;
//                               } catch (_) {}

//                               return _DropDownField(
//                                 hint: displayValue,
//                                 items: types,
//                                 onChanged: (val) {
//                                   try {
//                                     final selected = vehicleTypes.firstWhere(
//                                       (e) => e.vehicleName == val,
//                                     );
//                                     setState(() {
//                                       selectedVehicleType = val;
//                                       selectedVehicleTypeId = selected.id;
//                                     });
//                                   } catch (_) {}
//                                 },
//                               );
//                             },
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: _DatePickerField(
//                             displayDate: formatDisplayDate(
//                               widget.role.toLowerCase().contains("2")
//                                   ? testDate
//                                   : collectionDate,
//                             ),
//                             onTap: () async {
//                               final date = await showDatePicker(
//                                 context: context,
//                                 initialDate: DateTime.now(),
//                                 firstDate: DateTime(2000),
//                                 lastDate: DateTime.now(),
//                               );
//                               if (date != null) {
//                                 setState(() {
//                                   if (widget.role.toLowerCase().contains("2")) {
//                                     testDate =
//                                         "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
//                                     // Auto-calculate Next Test Due Date
//                                     final provider = context
//                                         .read<HomeProvider>();
//                                     final years =
//                                         provider
//                                             .state
//                                             .homeData
//                                             ?.data
//                                             ?.firstOrNull
//                                             ?.intervalTesting ??
//                                         3;
//                                     try {
//                                       final nextDate = DateTime(
//                                         date.year + years,
//                                         date.month,
//                                         date.day,
//                                       ).subtract(const Duration(days: 1));
//                                       nextTestDate =
//                                           "${nextDate.day.toString().padLeft(2, '0')}-${nextDate.month.toString().padLeft(2, '0')}-${nextDate.year}";
//                                     } catch (e) {
//                                       debugPrint(
//                                         "Error calculating next test date: $e",
//                                       );
//                                     }
//                                   } else {
//                                     collectionDate =
//                                         "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
//                                   }
//                                 });
//                               }
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                     if (widget.role.toLowerCase().contains("2")) ...[
//                       const SizedBox(height: 15),
//                       const _RowLabels(l1: "Next Test Due Date", l2: ""),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _ValueBox(
//                               text:
//                                   formatDisplayDate(nextTestDate) ??
//                                   "Auto Calculated",
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           const Expanded(child: SizedBox()),
//                         ],
//                       ),
//                     ],
//                     const SizedBox(height: 15),
//                     const _RowLabels(
//                       l1: "Choose Vehicle Format",
//                       l2: "Add Vehicle Number",
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Consumer<HomeProvider>(
//                             builder: (context, provider, _) {
//                               final formats =
//                                   provider.state.vehicleFormatData?.data
//                                       ?.map((e) => e.vFormat ?? "")
//                                       .toList() ??
//                                   [];
//                               return _DropDownField(
//                                 hint: selectedVehicleFormat ?? "Format",
//                                 items: formats,
//                                 onChanged: (val) =>
//                                     setState(() => selectedVehicleFormat = val),
//                               );
//                             },
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: _ManualField(
//                             hint: "Number",
//                             controller: vehicleNumberController,
//                             textCapitalization: TextCapitalization.characters,
//                             keyboardType:
//                                 (selectedVehicleFormat != null &&
//                                     !selectedVehicleFormat!
//                                         .toUpperCase()
//                                         .contains('X'))
//                                 ? TextInputType.number
//                                 : TextInputType.visiblePassword,
//                             inputFormatters: [
//                               LengthLimitingTextInputFormatter(
//                                 selectedVehicleFormat?.length ?? 13,
//                               ),
//                               VehicleNumberSmartFormatter(
//                                 selectedVehicleFormat,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 15),
//                     const _RowLabels(
//                       l1: "Select Dealer Name",
//                       l2: "Enter Mobile No.",
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Consumer<HomeProvider>(
//                             builder: (context, provider, _) {
//                               final dealerList =
//                                   provider.state.dealerTypeData?.data ?? [];
//                               final dealers = dealerList
//                                   .map((e) => e.fullname ?? "")
//                                   .toList();

//                               // 🔹 Handle displaying name if we only have ID
//                               String displayValue = selectedDealer ?? "Dealer";
//                               if (selectedDealerId != null) {
//                                 try {
//                                   final match = dealerList.firstWhere(
//                                     (e) => e.id == selectedDealerId,
//                                   );
//                                   displayValue = match.fullname ?? displayValue;
//                                 } catch (_) {}
//                               } else if (int.tryParse(displayValue) != null) {
//                                 try {
//                                   final match = dealerList.firstWhere(
//                                     (e) => e.id.toString() == displayValue,
//                                   );
//                                   displayValue = match.fullname ?? displayValue;
//                                   // Sync ID if found
//                                   selectedDealerId = match.id;
//                                 } catch (_) {}
//                               }

//                               return _DropDownField(
//                                 hint: displayValue,
//                                 items: dealers,
//                                 onChanged: (val) {
//                                   try {
//                                     final selected = dealerList.firstWhere(
//                                       (e) => e.fullname == val,
//                                     );
//                                     setState(() {
//                                       selectedDealer = val;
//                                       selectedDealerId = selected.id;
//                                     });
//                                   } catch (_) {}
//                                 },
//                               );
//                             },
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: _ManualField(
//                             hint: "Mobile",
//                             controller: mobileNumberController,
//                             keyboardType: TextInputType.phone,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               /// 🔹 Product Details
//               _buildSectionHeader("Product Details"),
//               _buildActionCard(
//                 child: Column(
//                   children: [
//                     const _RowLabels(
//                       l1: "Product Type",
//                       l2: "Cylinder Specification",
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _ValueBox(
//                             text: widget.certificate.productType ?? "N/A",
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: _ValueBox(
//                             text: widget.certificate.specification ?? "N/A",
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 15),
//                     const _RowLabels(
//                       l1: "Sl No/Balance Cylinder No:",
//                       l2: "Last Testing Date",
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _ManualField(
//                             hint: "Cylinder Serial No",
//                             controller: serialNoController,
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: _DatePickerField(
//                             displayDate: formatDisplayDate(lastTestingDate),
//                             onTap: () async {
//                               final date = await showDatePicker(
//                                 context: context,
//                                 initialDate: DateTime.now(),
//                                 firstDate: DateTime(2000),
//                                 lastDate: DateTime.now(),
//                               );
//                               if (date != null) {
//                                 setState(() {
//                                   lastTestingDate =
//                                       "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
//                                 });
//                               }
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 15),
//                     const _RowLabels(
//                       l1: "Cylinder Make",
//                       l2: "Manufacturing Date",
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Consumer<HomeProvider>(
//                             builder: (context, provider, _) {
//                               final data =
//                                   provider.state.cylinderMakeData?.data ?? [];
//                               final items = data
//                                   .map((e) => e.fullname ?? "")
//                                   .toList();
//                               return _DropDownField(
//                                 hint: selectedCylinderMakeName ?? "Select",
//                                 items: items,
//                                 onChanged: (v) {
//                                   final selected = data.firstWhere(
//                                     (e) => e.fullname == v,
//                                   );
//                                   setState(() {
//                                     selectedCylinderMakeName = v;
//                                     selectedCylinderMakeId = selected.id
//                                         ?.toString();
//                                   });
//                                 },
//                               );
//                             },
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: _DatePickerField(
//                                   displayDate:
//                                       manufacturingMonthController.text.isEmpty
//                                       ? "Month"
//                                       : manufacturingMonthController.text,
//                                   onTap: () {
//                                     showDialog(
//                                       context: context,
//                                       builder: (context) {
//                                         final List<String> monthNames = [
//                                           "January",
//                                           "February",
//                                           "March",
//                                           "April",
//                                           "May",
//                                           "June",
//                                           "July",
//                                           "August",
//                                           "September",
//                                           "October",
//                                           "November",
//                                           "December",
//                                         ];
//                                         return AlertDialog(
//                                           title: const Text("Select Month"),
//                                           content: SizedBox(
//                                             width: 300,
//                                             height: 300,
//                                             child: ListView.builder(
//                                               itemCount: 12,
//                                               itemBuilder: (context, index) {
//                                                 return ListTile(
//                                                   title: Text(
//                                                     monthNames[index],
//                                                   ),
//                                                   onTap: () {
//                                                     setState(() {
//                                                       manufacturingMonthController
//                                                               .text =
//                                                           monthNames[index];
//                                                       _syncFillingPermDate();
//                                                       _syncExpiryDate();
//                                                     });
//                                                     Navigator.pop(context);
//                                                   },
//                                                 );
//                                               },
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(width: 5),
//                               Expanded(
//                                 child: _DatePickerField(
//                                   displayDate:
//                                       manufacturingYearController.text.isEmpty
//                                       ? "Year"
//                                       : manufacturingYearController.text,
//                                   onTap: () {
//                                     showDialog(
//                                       context: context,
//                                       builder: (context) {
//                                         return AlertDialog(
//                                           title: const Text("Select Year"),
//                                           content: SizedBox(
//                                             width: 300,
//                                             height: 300,
//                                             child: YearPicker(
//                                               firstDate: DateTime(2000),
//                                               lastDate: DateTime.now(),
//                                               selectedDate: DateTime.now(),
//                                               onChanged: (DateTime dateTime) {
//                                                 setState(() {
//                                                   manufacturingYearController
//                                                       .text = dateTime.year
//                                                       .toString();
//                                                   _syncFillingPermDate();
//                                                   _syncExpiryDate();
//                                                 });
//                                                 Navigator.pop(context);
//                                               },
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     if (widget.role.toLowerCase().contains("2")) ...[
//                       const SizedBox(height: 15),
//                       const _RowLabels(
//                         l1: "CCE No(gas Filling Perm: (No",
//                         l2: "Filling Permission Date",
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _ManualField(
//                               hint: "CCE Number",
//                               controller: cceNoController,
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: _DatePickerField(
//                               displayDate: formatDisplayDate(fillingPermDate),
//                               onTap: () async {
//                                 final date = await showDatePicker(
//                                   context: context,
//                                   initialDate: DateTime.now(),
//                                   firstDate: DateTime(2000),
//                                   lastDate: DateTime.now(),
//                                 );
//                                 if (date != null) {
//                                   setState(() {
//                                     fillingPermDate =
//                                         "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
//                                   });
//                                 }
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                     if (widget.role.toLowerCase().contains("2")) ...[
//                       const SizedBox(height: 15),
//                       Row(
//                         children: [
//                           const Text(
//                             "Expiry Date",
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           if (isCylinderExpired) ...[
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Text(
//                                 "your cylinder expire you can not perform test",
//                                 style: const TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.red,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _ValueBox(
//                               text: expiryYearController.text.isEmpty
//                                   ? "Auto Calculated"
//                                   : expiryYearController.text,
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           const Expanded(child: SizedBox()),
//                         ],
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),

//               /// 🔹 Testing Details - Role 2 only
//               if (widget.role.toLowerCase().contains("2") &&
//                   !isCylinderExpired) ...[
//                 _buildSectionHeader("Testing Details"),
//                 _buildActionCard(
//                   child: Column(
//                     children: [
//                       const _RowLabels(
//                         l1: "Valve Inspection",
//                         l2: "Visual Inspection",
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _DropDownField(
//                               hint: initialStatus ?? "OK",
//                               items: const ["OK", "Not OK"],
//                               onChanged: (v) =>
//                                   setState(() => initialStatus = v),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: _DropDownField(
//                               hint: visualStatus ?? "OK",
//                               items: const ["OK", "Not OK"],
//                               onChanged: (v) =>
//                                   setState(() => visualStatus = v),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 15),
//                       const _RowLabels(
//                         l1: "Cylinder Threading",
//                         l2: "Internal Inspection",
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _DropDownField(
//                               hint: threadingStatus ?? "OK",
//                               items: const ["OK", "Not OK"],
//                               onChanged: (v) =>
//                                   setState(() => threadingStatus = v),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: _DropDownField(
//                               hint: internalStatus ?? "OK",
//                               items: const ["OK", "Not OK"],
//                               onChanged: (v) =>
//                                   setState(() => internalStatus = v),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 15),
//                       const _RowLabels(
//                         l1: "Original T.W (Stamped Weight)",
//                         l2: "Actual Weight (Measured Weight)",
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _ManualField(
//                               hint: "Original Tare Weigh",
//                               keyboardType: TextInputType.number,
//                               controller: tareWeightController,
//                               onChanged: (_) => _calculateWeightLoss(),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: _ManualField(
//                               hint: "Actual Weight",
//                               controller: actualWeightController,
//                               keyboardType: TextInputType.number,
//                               onChanged: (_) => _calculateWeightLoss(),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 15),
//                       const _RowLabels(
//                         l1: "Loss Of Weight(Kg...)",
//                         l2: "Loss Of Weight(%)",
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _ValueBox(
//                               text: weightLossKgController.text.isEmpty
//                                   ? "0.00"
//                                   : weightLossKgController.text,
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: _ValueBox(
//                               text: weightLossPctController.text.isEmpty
//                                   ? "0.00%"
//                                   : "${weightLossPctController.text}%",
//                             ),
//                           ),
//                         ],
//                       ),
//                       if (weightErrorMessage != null) ...[
//                         const SizedBox(height: 10),
//                         Container(
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: Colors.red.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             weightErrorMessage!,
//                             style: const TextStyle(
//                               color: Colors.red,
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                       const SizedBox(height: 15),
//                       const _RowLabels(
//                         l1: "Plate Condition",
//                         l2: "Dia of The Cylinder(mm)",
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _DropDownField(
//                               hint: plateStatus ?? "OK",
//                               items: const ["OK", "Not OK"],
//                               onChanged: (v) => setState(() => plateStatus = v),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: _ManualField(
//                               hint: "Size Of The Cylinder",
//                               controller: cylinderSizeController,
//                               keyboardType: TextInputType.number,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 /// 🔹 Cylinder Wall Thickness - Role 2 only
//                 _buildSectionHeader("Cylinder Wall Thickness"),
//                 _buildActionCard(
//                   child: Column(
//                     children: [
//                       const Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           "Shell (mm)",
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _ManualField(
//                               hint: "Minimum Calculate",
//                               keyboardType: TextInputType.number,
//                               controller: shellMinController,
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: _ManualField(
//                               hint: "Observed Thickness",
//                               keyboardType: TextInputType.number,
//                               controller: shellObsController,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 15),
//                       const Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           "Thickness of the Center of the Bottom",
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _ManualField(
//                               hint: "Minimum Calculate",
//                               controller: bottomMinController,
//                               keyboardType: TextInputType.number,
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: _ManualField(
//                               hint: "Observed Thickness",
//                               controller: bottomObsController,
//                               keyboardType: TextInputType.number,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],

//               /// 🔹 Hydrostatic Test Details (Expansion) - Role 2 only
//               if (widget.role.toLowerCase().contains("2")) ...[
//                 if (isCylinderExpired)
//                   Container(
//                     margin: const EdgeInsets.symmetric(vertical: 10),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.orange.withOpacity(0.5)),
//                     ),
//                     child: const Text(
//                       "Cylinder has expired. Some details are hidden.",
//                       style: TextStyle(
//                         color: Colors.orange,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 _buildSectionHeader("Hydrostatic Test Details"),
//                 _buildActionCard(
//                   child: Column(
//                     children: [
//                       const _RowLabels(l1: "Water Capacity (L)", l2: "Result"),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _ManualField(
//                               hint: "Capacity",
//                               controller: capacityController,
//                               keyboardType: TextInputType.number,
//                             ),
//                           ),
//                           if (!isCylinderExpired) ...[
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: _DropDownField(
//                                 hint: selectedResult ?? "PASS",
//                                 items: const ["PASS", "FAIL"],
//                                 onChanged: (v) =>
//                                     setState(() => selectedResult = v),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                       if (!isCylinderExpired) ...[
//                         const SizedBox(height: 15),
//                         const _RowLabels(
//                           l1: "Working Pressure",
//                           l2: "Test Pressure",
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _ValueBox(
//                                 text:
//                                     widget.certificate.workingPressure ?? "204",
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: _ValueBox(
//                                 text: widget.certificate.testPressure ?? "340",
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 15),
//                         const _RowLabels(
//                           l1: "Initial Expansion",
//                           l2: "Total Expansion",
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _ManualField(
//                                 hint: "Initial",
//                                 controller: expansionInitialController,
//                                 keyboardType: TextInputType.number,
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: _ManualField(
//                                 hint: "Total",
//                                 controller: expansionTotalController,
//                                 keyboardType: TextInputType.number,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 15),
//                         const _RowLabels(
//                           l1: "Permanent Exp.",
//                           l2: "Permanent Exp (%)",
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _ManualField(
//                                 hint: "Permanent",
//                                 controller: expansionPermController,
//                                 keyboardType: TextInputType.number,
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: _ManualField(
//                                 hint: "Percentage",
//                                 controller: expansionPctController,
//                                 keyboardType: TextInputType.number,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//               ],

//               /// 🔹 Photo Uploads
//               _buildSectionHeader("Photo Uploads"),
//               _buildActionCard(
//                 child: Column(
//                   children: [
//                     if (!isCylinderExpired) ...[
//                       DashedUploadArea(
//                         title: "Update Photo of Number Plate",
//                         onPick: () => _pickAndCompressImage("plate"),
//                         imagePath: pickedImages["plate"],
//                         networkImageUrl:
//                             widget.certificate.photoNumberPlate != null &&
//                                 widget.certificate.photoNumberPlate!.isNotEmpty
//                             ? "https://pe.microcmd.com/API/uploads/${widget.certificate.photoNumberPlate}"
//                             : null,
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                     if (widget.role.toLowerCase().contains("2")) ...[
//                       DashedUploadArea(
//                         title: "Update Photo of Cylinder Marking",
//                         onPick: () => _pickAndCompressImage("neck"),
//                         imagePath: pickedImages["neck"],
//                         networkImageUrl:
//                             widget.certificate.photoMarkingDetails != null &&
//                                 widget
//                                     .certificate
//                                     .photoMarkingDetails!
//                                     .isNotEmpty
//                             ? "https://pe.microcmd.com/API/uploads/${widget.certificate.photoMarkingDetails}"
//                             : null,
//                       ),
//                     ],
//                   ],
//                 ),
//               ),

//               /// 🔹 Remarks - Role 2 only
//               if (widget.role.toLowerCase().contains("2")) ...[
//                 _buildSectionHeader("Remarks"),
//                 _buildActionCard(
//                   child: _ManualField(
//                     hint: "Remarks",
//                     controller: remarksController,
//                     maxLines: 3,
//                   ),
//                 ),
//               ],

//               const SizedBox(height: 40),

//               /// 🔹 Update Button
//               Consumer<HomeProvider>(
//                 builder: (context, provider, _) {
//                   return CustomButton(
//                     text: "Update Certificate",
//                     isLoading:
//                         provider.state.certificateStatus == HomeStatus.loading,
//                     onPressed: () async {
//                       if (!_formKey.currentState!.validate()) return;
//                       final authRepo = context.read<AuthRepository>();
//                       final userId = await authRepo.getUserId();
//                       final provider = context.read<HomeProvider>();

//                       // Attempt to find vehicle type ID if we only have the name
//                       String? vehType = selectedVehicleTypeId?.toString();
//                       if (vehType == null &&
//                           widget.certificate.vehicalType != null) {
//                         final typeName = widget.certificate.vehicalType
//                             .toString();
//                         final vehicleTypes =
//                             provider.state.vehicleTypeData?.data;
//                         if (vehicleTypes != null && vehicleTypes.isNotEmpty) {
//                           final match = vehicleTypes.firstWhere(
//                             (e) => e.vehicleName == typeName,
//                             orElse: () => vehicleTypes.first,
//                           );
//                           vehType = match.id?.toString();
//                         }
//                       }

//                       bool isRole2 = widget.role.toLowerCase().contains("2");
//                       final Map<String, dynamic> data = {
//                         'dealer_name': selectedDealerId?.toString() ?? '',
//                         'dealer': selectedDealerId?.toString() ?? '',
//                         'photo_number_plate': pickedImages['plate'],
//                         'photo_marking_details': pickedImages['neck'],
//                         'adminid': widget.certificate.adminId?.toString() ?? '',
//                         'license_name': 'PREMIUM HYDRO ENGINEERING',
//                         'approval_no': 'AG/HQ/GJ/GCT/1G49051',
//                         'vehical_type': '${selectedVehicleType ?? ''}',
//                         'vehicle_number': '${vehicleNumberController.text}',
//                         'vehicle_format': '${selectedVehicleFormat ?? ''}',
//                         'test_date': '${testDate ?? ''}',
//                         'collection_date':
//                             ' ${testDate ?? collectionDate ?? ''}',
//                         'next_test_date': '${nextTestDate ?? ''}',
//                         'product_type': 'Compress Natural Gas',
//                         'specification': 'IS 15490',
//                         'cylinder_serial_no': '${serialNoController.text}',
//                         'last_test_date': '${lastTestingDate ?? ''}',
//                         'cylinder_make': '${selectedCylinderMakeId ?? ''}',
//                         'manufacturing_date':
//                             ' ${() {
//                               final List<String> monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
//                               String monthStr = manufacturingMonthController.text.trim();
//                               int mIdx = monthNames.indexOf(monthStr);
//                               String mm = (mIdx != -1) ? (mIdx + 1).toString().padLeft(2, '0') : '01';
//                               return '01-$mm-${manufacturingYearController.text}';
//                             }()}',
//                         'cce_filling_permission_no': '${cceNoController.text}',
//                         'filling_permission_date': '${fillingPermDate ?? ''}',
//                         'expire_date':
//                             ' ${() {
//                               if (expiryYearController.text.contains("-")) {
//                                 final p = expiryYearController.text.split("-");
//                                 if (p[0].length == 4) return "01-${p[1]}-${p[0]}";
//                               }
//                               return expiryYearController.text;
//                             }()}',
//                         'valve_inspection':
//                             '${initialStatus == "OK" ? "0" : "1"}',
//                         'valve_inspection_remark': initialObsController.text,
//                         'visual_inspection':
//                             '${visualStatus == "OK" ? "0" : "1"}',
//                         'visual_inspection_remark': visualObsController.text,
//                         'cylinder_threading':
//                             '${threadingStatus == "OK" ? "0" : "1"}',
//                         'cylinder_threading_remark':
//                             threadingObsController.text,
//                         'internal_inspection':
//                             '${internalStatus == "OK" ? "0" : "1"}',
//                         'internal_inspection_remark':
//                             internalObsController.text,
//                         'original_tare_weight': tareWeightController.text,
//                         'actual_weight': actualWeightController.text,
//                         'loss_of_weight': weightLossKgController.text,
//                         'loss_of_weight_percentage':
//                             weightLossPctController.text,
//                         'painting': '0',
//                         'die_of_cylinder': cylinderSizeController.text,
//                         'shell_min_cal_thick': shellMinController.text,
//                         'shell_obs_thick_min': shellObsController.text,
//                         'bottom_min_cal_thick': bottomMinController.text,
//                         'bottom_obs_thick_min': bottomObsController.text,
//                         'water_capacity': capacityController.text,
//                         'working_pressure':
//                             (widget.certificate.workingPressure ?? '204')
//                                 .toString(),
//                         'test_pressure':
//                             (widget.certificate.testPressure ?? '340')
//                                 .toString(),
//                         'initial_expansion': expansionInitialController.text,
//                         'total_expansion': expansionTotalController.text,
//                         'permanent_expansion': expansionPermController.text,
//                         'permanent_expansion_percentage':
//                             expansionPctController.text,
//                         'result': selectedResult ?? 'PASS',
//                         'remark': remarksController.text,
//                         'userid': userId ?? '4',
//                         'mobile_no': mobileNumberController.text,
//                         'status': ' 2',
//                         'id': widget.certificate.id.toString(),
//                         'certificate_id': widget.certificate.id.toString(),
//                       };
//                       print('certificate data ---> ${data}');
//                       bool success = false;
//                       if (context.mounted) {
//                         if (widget.role.toLowerCase().contains("2")) {
//                           success = await provider.updateRole2Certificate(
//                             data,
//                             context,
//                           );
//                         } else {
//                           success = await provider.updateRole1Certificate(
//                             data,
//                             context,
//                           );
//                         }
//                       }
//                       //   }
//                       // }

//                       if (success && context.mounted) {
//                         showDialog(
//                           context: context,
//                           barrierDismissible: false,
//                           builder: (context) {
//                             return Dialog(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: FadeInUp(
//                                 duration: const Duration(milliseconds: 300),
//                                 child: Container(
//                                   padding: const EdgeInsets.all(25),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Container(
//                                         height: 70,
//                                         width: 70,
//                                         decoration: BoxDecoration(
//                                           color: Colors.green.withOpacity(0.1),
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: const Icon(
//                                           Icons.check_circle_rounded,
//                                           color: Colors.green,
//                                           size: 40,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 20),
//                                       const Text(
//                                         "Success!",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 22,
//                                           color: Colors.black87,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 10),
//                                       const Text(
//                                         "Certificate updated successfully.",
//                                         style: TextStyle(
//                                           color: Colors.grey,
//                                           fontSize: 15,
//                                         ),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                       const SizedBox(height: 30),
//                                       SizedBox(
//                                         width: double.infinity,
//                                         child: ElevatedButton(
//                                           onPressed: () {
//                                             Navigator.pop(
//                                               context,
//                                             ); // Close dialog
//                                             Navigator.pop(
//                                               context,
//                                             ); // Go back to list
//                                           },
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: AppColors.primary,
//                                             padding: const EdgeInsets.symmetric(
//                                               vertical: 15,
//                                             ),
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                           ),
//                                           child: const Text(
//                                             "OK",
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                       }
//                     },
//                   );
//                 },
//               ),
//               const SizedBox(height: 50),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//       decoration: const BoxDecoration(
//         color: AppColors.primary,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(15),
//           topRight: Radius.circular(15),
//         ),
//       ),
//       child: Text(
//         title,
//         style: const TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: 16,
//         ),
//       ),
//     );
//   }

//   Widget _buildActionCard({required Widget child}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       margin: const EdgeInsets.only(bottom: 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(color: Colors.grey.shade200),
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(15),
//           bottomRight: Radius.circular(15),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
// }

// // 🔹 Reusable Local Widgets for clean code
// class _ValueBox extends StatelessWidget {
//   final String text;
//   const _ValueBox({required this.text});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontSize: 13,
//           color: Colors.black87,
//           fontWeight: FontWeight.bold,
//         ),
//         overflow: TextOverflow.ellipsis,
//       ),
//     );
//   }
// }

// class _RowLabels extends StatelessWidget {
//   final String l1, l2;
//   const _RowLabels({required this.l1, required this.l2});
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             l1,
//             style: const TextStyle(
//               fontSize: 12,
//               color: Colors.grey,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             l2,
//             style: const TextStyle(
//               fontSize: 12,
//               color: Colors.grey,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _DropDownField extends StatelessWidget {
//   final String hint;
//   final List<String> items;
//   final Function(String?) onChanged;
//   const _DropDownField({
//     required this.hint,
//     required this.items,
//     required this.onChanged,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           isExpanded: true,
//           hint: Text(
//             hint,
//             style: const TextStyle(fontSize: 12, color: Colors.black87),
//           ),
//           items: items
//               .map(
//                 (e) => DropdownMenuItem(
//                   value: e,
//                   child: Text(e, style: const TextStyle(fontSize: 12)),
//                 ),
//               )
//               .toList(),
//           onChanged: onChanged,
//         ),
//       ),
//     );
//   }
// }

// class _DatePickerField extends StatelessWidget {
//   final String? displayDate;
//   final VoidCallback onTap;
//   const _DatePickerField({this.displayDate, required this.onTap});
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade50,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.grey.shade300),
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 displayDate ?? "DD-MM-YYYY",
//                 style: const TextStyle(fontSize: 12, color: Colors.black87),
//               ),
//             ),
//             const Icon(
//               Icons.calendar_today,
//               size: 16,
//               color: AppColors.primary,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ManualField extends StatelessWidget {
//   final String hint;
//   final TextEditingController controller;
//   final TextInputType? keyboardType;
//   final TextCapitalization textCapitalization;
//   final List<TextInputFormatter>? inputFormatters;
//   final int maxLines;
//   final Function(String)? onChanged;

//   const _ManualField({
//     required this.hint,
//     required this.controller,
//     this.keyboardType,
//     this.textCapitalization = TextCapitalization.none,
//     this.inputFormatters,
//     this.maxLines = 1,
//     this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: TextField(
//         controller: controller,
//         style: const TextStyle(fontSize: 13),
//         keyboardType: keyboardType,
//         textCapitalization: textCapitalization,
//         inputFormatters: inputFormatters,
//         maxLines: maxLines,
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           hintText: hint,
//           border: InputBorder.none,
//           hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
//         ),
//       ),
//     );
//   }
// }
