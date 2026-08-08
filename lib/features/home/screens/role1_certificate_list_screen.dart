import 'package:flutter/material.dart';
import 'package:premium_engneering_app/features/auth/data/auth_repository.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../provider/home_provider.dart';
import '../widgets/home_tables.dart';

class Role1CertificateListScreen extends StatefulWidget {
  const Role1CertificateListScreen({super.key});

  @override
  State<Role1CertificateListScreen> createState() => _Role1CertificateListScreenState();
}

class _Role1CertificateListScreenState extends State<Role1CertificateListScreen> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authRepo = context.read<AuthRepository>();
      final userId = await authRepo.getUserId();
      final name = await authRepo.getUserName();

      if (mounted) {
        setState(() {
          _userName = name;
        });
        final provider = context.read<HomeProvider>();
           provider.updateSearchQuery("");
       await provider.getCertificateList(userId ?? "", 'role_1');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Certificate Details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 🔹 Dashboard Style Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
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
                  Row(
                    children: [
                      Text(
                        "Welcome : ",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _userName != null && _userName!.isNotEmpty
                            ? '${_userName![0].toUpperCase()}${_userName!.substring(1).toLowerCase()}'
                            : (''),
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


            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search & Entries
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Container(
                            height: 35,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: '10',
                                items: ['10', '25', '50'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (_) {},
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                              ),
                              child: TextField(
                                onChanged: (v) {
                                  context.read<HomeProvider>().updateSearchQuery(v);
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintText: "Search certificates...",
                                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                                  contentPadding: EdgeInsets.only(bottom: 5, top: 10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Table Wrapper for horizontal scroll
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue.shade200),
                      color: Colors.white,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Role1Table(role: "role_1"),
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "Showing 1 to 1 of 1 entry",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),

                  // Pagination
                  Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "1",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
