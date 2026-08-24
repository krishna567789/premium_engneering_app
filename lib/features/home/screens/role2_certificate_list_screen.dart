import 'package:flutter/material.dart';
import 'package:premium_engneering_app/features/auth/data/auth_repository.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../provider/home_provider.dart';
import '../widgets/home_tables.dart';

class Role2CertificateListScreen extends StatefulWidget {
  const Role2CertificateListScreen({super.key});

  @override
  State<Role2CertificateListScreen> createState() =>
      _Role2CertificateListScreenState();
}

class _Role2CertificateListScreenState
    extends State<Role2CertificateListScreen> {
  String? _userName;
  int _currentPage = 1;
  int _itemsPerPage = 10;
  String _selectedResultFilter = "All";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authRepo = context.read<AuthRepository>();
      final adminId = await authRepo.getAdminId();
      final name = await authRepo.getUserName();

      if (mounted) {
        setState(() => _userName = name);
        final provider = context.read<HomeProvider>();
        provider.updateSearchQuery("");
        await provider.getCertificateList(adminId ?? "", 'role_2');
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
          "Certificate Details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                  const Spacer(),
                  Text(
                    "Welcome : ${_userName?.toUpperCase() ?? ''}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Consumer<HomeProvider>(
                builder: (context, provider, child) {
                  final state = provider.state;
                  var allCertificates =
                      state.role2CertificateListData?.role1certificateList ??
                      [];

                  // Apply Result Filter
                  if (_selectedResultFilter != "All") {
                    allCertificates = allCertificates.where((cert) {
                      final status = cert.certificateStatus?.toUpperCase();
                      if (_selectedResultFilter == "PASS") {
                        return status == "PASS" || cert.result?.toUpperCase() == "PASS";
                      } else if (_selectedResultFilter == "FAIL") {
                        return status == "FAIL" || cert.result?.toUpperCase() == "FAIL";
                      }
                      return true;
                    }).toList();
                  }

                  if (state.searchQuery.isNotEmpty) {
                    final query = state.searchQuery.toLowerCase();
                    allCertificates = allCertificates.where((cert) {
                      return (cert.certificateNo?.toLowerCase().contains(
                                query,
                              ) ??
                              false) ||
                          (cert.cNo?.toLowerCase().contains(query) ?? false) ||
                          (cert.dealerName?.toLowerCase().contains(query) ??
                              false) ||
                          (cert.vehicleNumber?.toLowerCase().contains(query) ??
                              false) ||
                          (cert.displayNumber?.toLowerCase().contains(query) ??
                              false) ||
                          (cert.mobile?.toLowerCase().contains(query) ?? false);
                    }).toList();
                  }
                  int totalEntries = allCertificates.length;
                  int totalPages = (totalEntries / _itemsPerPage).ceil();
                  if (totalPages == 0) totalPages = 1;
                  if (_currentPage > totalPages) _currentPage = totalPages;
                  int startIndex = (_currentPage - 1) * _itemsPerPage;
                  int endIndex = startIndex + _itemsPerPage;
                  if (endIndex > totalEntries) endIndex = totalEntries;
                  var paginatedCertificates = allCertificates.sublist(
                    startIndex,
                    endIndex,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 35,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: theme.inputDecorationTheme.fillColor,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _itemsPerPage.toString(),
                                dropdownColor: theme.cardColor,
                                items: ['10', '25', '50']
                                    .map(
                                      (String value) =>
                                          DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: theme
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color,
                                              ),
                                            ),
                                          ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() {
                                      _itemsPerPage = int.parse(v);
                                      _currentPage = 1;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            height: 35,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: theme.inputDecorationTheme.fillColor,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedResultFilter,
                                dropdownColor: theme.cardColor,
                                items: ['All', 'PASS', 'FAIL']
                                    .map(
                                      (String value) =>
                                          DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: theme
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.color,
                                              ),
                                            ),
                                          ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() {
                                      _selectedResultFilter = v;
                                      _currentPage = 1;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              decoration: BoxDecoration(
                                color: theme.inputDecorationTheme.fillColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: TextField(
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                                onChanged: (v) {
                                  provider.updateSearchQuery(v);
                                  setState(() => _currentPage = 1);
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText: "Search certificates...",
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                  contentPadding: const EdgeInsets.only(
                                    bottom: 5,
                                    top: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                          color: theme.cardColor,
                        ),
                        child: Role2Table(
                          role: "role_2",
                          certificates: paginatedCertificates,
                          status: state.role2CertificateListStatus,
                          errorMessage: state.errorMessage ?? "",
                        ),
                      ),

                      const SizedBox(height: 25),
                      Text(
                        "Showing ${totalEntries > 0 ? startIndex + 1 : 0} to $endIndex of $totalEntries entry",
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, size: 16),
                            onPressed: _currentPage > 1
                                ? () => setState(() => _currentPage--)
                                : null,
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "$_currentPage",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 16),
                            onPressed: _currentPage < totalPages
                                ? () => setState(() => _currentPage++)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
