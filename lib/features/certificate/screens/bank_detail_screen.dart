import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:premium_engneering_app/features/home/provider/home_provider.dart';
import 'package:premium_engneering_app/features/home/provider/home_state.dart';
import 'package:provider/provider.dart';
import '../../auth/data/auth_repository.dart';
import '../../../core/theme.dart';
import '../../../widgets/custom_widgets.dart';

class BankDetailScreen extends StatefulWidget {
  final String certNo;
  final String holderName;
  final String? id;
  final String? dealerId;
  final String? pendingAmount;
  final String? totalAmount;

  const BankDetailScreen({
    super.key,
    required this.certNo,
    required this.holderName,
    this.id,
    this.dealerId,
    this.pendingAmount,
    this.totalAmount,
  });

  @override
  State<BankDetailScreen> createState() => _BankDetailScreenState();
}

class _BankDetailScreenState extends State<BankDetailScreen> {
  String? selectedPaymentMode;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController(
    text: "22-04-2026",
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HomeProvider>();
      provider.getPaymentMaster();
      if (widget.id != null) {
        provider.getTransactionHistory(widget.id!);
      }
      if (widget.dealerId != null) {
        provider.getDealerAmount(widget.dealerId!, certId: widget.id);
      }
    });
  }

  void _showPaymentModeSelection() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF333333),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Consumer<HomeProvider>(
          builder: (context, provider, child) {
            if (provider.state.paymentMasterStatus == HomeStatus.loading) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }
            if (provider.state.paymentMasterStatus == HomeStatus.error) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    provider.state.errorMessage ?? "Error fetching modes",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }

            final modes = provider.state.paymentMasterData?.data ?? [];

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select Payment Mode",
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                      Icon(
                        Icons.radio_button_checked,
                        color: Colors.teal.shade200,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                ...modes.map((mode) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSelectionOption(mode.pName),
                      const Divider(color: Colors.white24, height: 1),
                    ],
                  );
                }).toList(),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getDisplayPaymentMode(String mode) {
    if (mode.toLowerCase() == 'credit') return 'Credit card';
    return mode;
  }

  Widget _buildSelectionOption(String mode) {
    bool isSelected = selectedPaymentMode == mode;
    return ListTile(
      title: Text(
        _getDisplayPaymentMode(mode),
        style: const TextStyle(color: Colors.white70, fontSize: 18),
      ),
      trailing: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? Colors.teal.shade200 : Colors.white70,
        size: 20,
      ),
      onTap: () {
        setState(() {
          selectedPaymentMode = mode;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 15),
      backgroundColor: Colors.transparent,
      child: FadeInUp(
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E2141),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.credit_card,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Payment Details",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Amounts Row
                      Consumer<HomeProvider>(
                        builder: (context, provider, _) {
                          final collAmount =
                              provider.state.dealerAmount ??
                              widget.totalAmount ??
                              "0";
                          final pendAmount =
                              provider.state.dealerPendingAmount ??
                              (provider
                                          .state
                                          .transactionHistoryData
                                          ?.data
                                          .isNotEmpty ==
                                      true
                                  ? provider
                                        .state
                                        .transactionHistoryData!
                                        .data
                                        .first
                                        .pAmount
                                  : widget.pendingAmount ?? "0");

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildAmountLabel(
                                "Collection Amount",
                                collAmount,
                                Colors.green,
                              ),
                              _buildAmountLabel(
                                "Pending Amount",
                                pendAmount.toString(),
                                pendAmount == 'Completed'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 25),

                      // Input Labels
                      const Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Payment Mode",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              "Collected Amount",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Input Fields
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _showPaymentModeSelection,
                              child: Container(
                                height: 45,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _getDisplayPaymentMode(
                                          selectedPaymentMode ??
                                              "Select Payment Mode",
                                        ),
                                        style: TextStyle(
                                          color: selectedPaymentMode == null
                                              ? Colors.grey
                                              : Colors.black87,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Container(
                              height: 45,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "₹ Enter amount",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Payment Date
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Payment Date",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 45,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: dateController,
                          readOnly: true,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (date != null) {
                              setState(() {
                                dateController.text =
                                    "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Save Button
                      // if ((double.tryParse(widget.pendingAmount ?? "0") ?? 0) >
                      //     0)
                      Consumer<HomeProvider>(
                        builder: (context, provider, child) {
                          final pendAmount =
                              provider.state.dealerPendingAmount ??
                              (provider
                                          .state
                                          .transactionHistoryData
                                          ?.data
                                          .isNotEmpty ==
                                      true
                                  ? provider
                                        .state
                                        .transactionHistoryData!
                                        .data
                                        .first
                                        .pAmount
                                  : widget.pendingAmount ?? "0");

                          if (pendAmount == 'Completed') {
                            return const SizedBox.shrink();
                          }
                          return ElevatedButton.icon(
                            onPressed:
                                provider.state.certificateStatus ==
                                    HomeStatus.loading
                                ? null
                                : () async {
                                    if (selectedPaymentMode == null) {
                                      CustomToast.error(
                                        context,
                                        "Please select payment mode",
                                        top: true,
                                      );
                                      return;
                                    }
                                    if (amountController.text.isEmpty) {
                                      CustomToast.error(
                                        context,
                                        "Please enter amount",
                                        top: true,
                                      );
                                      return;
                                    }

                                    final authRepo = context
                                        .read<AuthRepository>();
                                    final userId = await authRepo.getUserId();
                                    final pendAmount =
                                        provider
                                                .state
                                                .transactionHistoryData
                                                ?.data
                                                .isNotEmpty ==
                                            true
                                        ? provider
                                              .state
                                              .transactionHistoryData!
                                              .data
                                              .first
                                              .pAmount
                                        : widget.pendingAmount ?? "0";

                                    final collAmount =
                                        provider.state.dealerAmount ??
                                        widget.totalAmount ??
                                        "0";
                                    final currentPendVal =
                                        provider.state.dealerPendingAmount ??
                                        pendAmount;

                                    final currentPend =
                                        double.tryParse(currentPendVal) ?? 0;
                                    final payAmt =
                                        double.tryParse(
                                          amountController.text,
                                        ) ??
                                        0;
                                    final totalAmt =
                                        double.tryParse(collAmount) ?? 0;

                                    // Rule: If pending amount is 0/null, use collection amount - enter amount, else pending amount - enter amount
                                    final double startingBalance =
                                        (currentPend == 0)
                                        ? totalAmt
                                        : currentPend;

                                    if (payAmt <= 0) {
                                      CustomToast.error(
                                        context,
                                        "Enter a valid amount",
                                        top: true,
                                      );
                                      return;
                                    }

                                    if (payAmt > startingBalance) {
                                      CustomToast.error(
                                        context,
                                        "Amount cannot exceed the ${currentPend == 0 ? 'Collection' : 'Pending'} amount ($startingBalance)",
                                        top: true,
                                      );
                                      return;
                                    }

                                    final String calculatedPending =
                                        (startingBalance - payAmt)
                                            .toStringAsFixed(2);

                                    final success = await provider
                                        .savePaymentRole1({
                                          'id': widget.id,
                                          'payment': amountController.text,
                                          'payment_mode': selectedPaymentMode,
                                          'date': dateController.text,
                                          'formattedName': widget.holderName,
                                          'user_id': userId ?? '',
                                          'dealer_id': widget.dealerId,
                                          'pendingAmount': calculatedPending,
                                        });

                                    if (success) {
                                      amountController.clear();
                                      if (widget.id != null) {
                                        provider.getTransactionHistory(
                                          widget.id!,
                                        );
                                      }

                                      // Refresh Certificate List
                                      if (context.mounted) {
                                        final authRepo = context
                                            .read<AuthRepository>();
                                        final userId = await authRepo
                                            .getUserId();
                                        final adminId = await authRepo
                                            .getAdminId();
                                        final role = await authRepo
                                            .getUserType();

                                        provider.getCertificateList(
                                          (role == 'role_2'
                                                  ? adminId
                                                  : userId) ??
                                              '',
                                          role ?? 'role_1',
                                        );
                                      }

                                      CustomToast.success(
                                        context,
                                        "Payment saved successfully",
                                        top: true,
                                      );
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    } else {
                                      CustomToast.error(
                                        context,
                                        "Failed to save payment",
                                        top: true,
                                      );
                                    }
                                  },
                            icon:
                                provider.state.certificateStatus ==
                                    HomeStatus.loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.check_box,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                            label: Text(
                              provider.state.certificateStatus ==
                                      HomeStatus.loading
                                  ? "Saving..."
                                  : "Save Payment",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E2141),
                              minimumSize: const Size(180, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),

                      // History Table
                      Consumer<HomeProvider>(
                        builder: (context, provider, child) {
                          if (provider.state.transactionHistoryStatus ==
                              HomeStatus.loading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final transactions =
                              provider.state.transactionHistoryData?.data ?? [];

                          return Table(
                            border: TableBorder.all(
                              color: Colors.blue.shade100,
                              width: 1,
                            ),
                            columnWidths: const {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(1.5),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(2),
                              4: FlexColumnWidth(2),
                            },
                            children: [
                              TableRow(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF5E67A2),
                                ),
                                children: [
                                  _buildTableHeader("Sr.no"),
                                  _buildTableHeader("P. Mode"),
                                  _buildTableHeader("Collect Amt."),
                                  _buildTableHeader("Pending Amt."),
                                  _buildTableHeader("Date"),
                                ],
                              ),
                              ...transactions.asMap().entries.map((entry) {
                                final index = entry.key + 1;
                                final t = entry.value;
                                return TableRow(
                                  children: [
                                    _buildDataCell(index.toString()),
                                    _buildDataCell(
                                      _getDisplayPaymentMode(t.pMode),
                                    ),
                                    _buildDataCell(t.rAmount.toString()),
                                    _buildDataCell(t.pAmount),
                                    _buildDataCell(t.collectDate),
                                  ],
                                );
                              }).toList(),
                              if (transactions.isEmpty)
                                TableRow(
                                  children: [
                                    _buildDataCell("-"),
                                    _buildDataCell("-"),
                                    _buildDataCell("-"),
                                    _buildDataCell("-"),
                                    _buildDataCell("-"),
                                  ],
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountLabel(String label, String value, Color valueColor) {
    return Row(
      children: [
        Text(
          "$label : ",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 10, color: Colors.black87),
        ),
      ),
    );
  }
}
