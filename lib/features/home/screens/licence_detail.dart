import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../widgets/custom_widgets.dart';
import '../widgets/home_components.dart';

class LicenceDetailScreen extends StatelessWidget {
  const LicenceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Licence Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeSectionHeader(title: "Compliance Information"),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  _buildDetailRow("Licence Name", "PREMIUM HYDRO ENGIN"),
                  const Divider(height: 30),
                  _buildDetailRow("Approval Number", "AG/HQ/GJ/GCT/1G4905"),
                  const Divider(height: 30),
                  _buildDetailRow("Status", "ACTIVE", isStatus: true),
                  const Divider(height: 30),
                  _buildDetailRow("Expiry Date", "31-Dec-2027"),
                ],
              ),
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: "Back to Home", 
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        Container(
          padding: isStatus ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4) : null,
          decoration: isStatus ? BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5),
          ) : null,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isStatus ? Colors.green : AppColors.textTitle,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
