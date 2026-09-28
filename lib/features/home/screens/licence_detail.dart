import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../widgets/custom_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../widgets/home_components.dart';

class LicenceDetailScreen extends StatefulWidget {
  final String? licenseName;
  final String? approvalNo;
  const LicenceDetailScreen({super.key, this.licenseName, this.approvalNo});

  @override
  State<LicenceDetailScreen> createState() => _LicenceDetailScreenState();
}

class _LicenceDetailScreenState extends State<LicenceDetailScreen> {
  late String _licenseName;
  late String _approvalNo;

  @override
  void initState() {
    super.initState();
    _licenseName =
        (widget.licenseName != null && widget.licenseName!.isNotEmpty)
        ? widget.licenseName!
        : "";
    _approvalNo = (widget.approvalNo != null && widget.approvalNo!.isNotEmpty)
        ? widget.approvalNo!
        : "";

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authRepo = context.read<AuthRepository>();
      final lic = await authRepo.getLicenseNo();
      final app = await authRepo.getApprovalNo();
      if (mounted) {
        setState(() {
          if (lic != null && lic.isNotEmpty) _licenseName = lic;
          if (app != null && app.isNotEmpty) _approvalNo = app;
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
          "Licence Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: theme.colorScheme.primary,
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
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  _buildDetailRow(context, "Licence Name", _licenseName),
                  const Divider(height: 30),
                  _buildDetailRow(context, "Approval Number", _approvalNo),
                  const Divider(height: 30),
                  _buildDetailRow(context, "Status", "ACTIVE", isStatus: true),
                  const Divider(height: 30),
                  _buildDetailRow(context, "Expiry Date", "31-Dec-2027"),
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

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isStatus = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Container(
          padding: isStatus
              ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
              : null,
          decoration: isStatus
              ? BoxDecoration(
                  color: isStatus ? Colors.green.withValues(alpha: 0.1) : null,
                  borderRadius: BorderRadius.circular(5),
                )
              : null,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isStatus ? Colors.green : theme.textTheme.bodyLarge?.color,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
