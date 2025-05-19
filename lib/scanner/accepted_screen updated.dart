import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AcceptedScreen extends StatefulWidget {
  final String token;

  const AcceptedScreen({super.key, required this.token});

  @override
  State<AcceptedScreen> createState() => _AcceptedScreenState();
}

class _AcceptedScreenState extends State<AcceptedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> requestedList = [];
  List<Map<String, dynamic>> completedList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchMedicineRequests();
  }

  Future<void> fetchMedicineRequests() async {
    if (widget.token.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final url = Uri.parse(
        'http://127.0.0.1:5566/request-fetch',
      ); // <-- Replace with your API
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final retCode = jsonBody['retCode'] ?? jsonBody['retcode'];

        if (retCode == "200" && jsonBody['data'] != null) {
          final List dataList = jsonBody['data'];
          Map<String, List<Map<String, dynamic>>> grouped = {};

          for (var item in dataList) {
            final medicine = item['medicine'] ?? {};
            final user = item['user'] ?? {};
            final userName =
                "${user['first_name'] ?? ''} ${user['last_name'] ?? ''}".trim();

            final medicineDetails = {
              'medicine_name': medicine['medicine_name'] ?? 'Unknown',
              'type': medicine['type_of_drug'] ?? 'Unknown',
              'quantity': item['quantity'] ?? 0,
              'batch_code': item['batch_code'] ?? 'Unknown',
              'milligram': medicine['milligram'] ?? '',
              'brand': medicine['brand'] ?? '',
              'expiration': medicine['expiration_date'] ?? '',
              'request_date': item['request_date'] ?? '',
            };

            final status = item['status'] == true ? 'completed' : 'requested';

            grouped.putIfAbsent(userName, () => []).add({
              ...medicineDetails,
              'status': status,
            });
          }

          requestedList = [];
          completedList = [];

          grouped.forEach((name, medicines) {
            final requested =
                medicines.where((m) => m['status'] == 'requested').toList();
            final completed =
                medicines.where((m) => m['status'] == 'completed').toList();

            if (requested.isNotEmpty) {
              requestedList.add({'name': name, 'medicines': requested});
            }
            if (completed.isNotEmpty) {
              completedList.add({'name': name, 'medicines': completed});
            }
          });
        }
      }
    } catch (e) {
      print('Error fetching requests: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget buildGroupCard(Map<String, dynamic> groupData) {
    String userName = groupData['name'];
    List<Map<String, dynamic>> medicines = List<Map<String, dynamic>>.from(
      groupData['medicines'],
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF004C72),
              child: Text(
                userName.isNotEmpty ? userName[0] : '',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                userName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children:
            medicines.map((medicine) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: medicines.length,
                      itemBuilder: (context, index) {
                        final medicine = medicines[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabeledDetail(
                                "Medicine",
                                medicine['medicine_name'],
                              ),
                              _buildLabeledDetail("Brand", medicine['brand']),
                              _buildLabeledDetail(
                                "Milligram",
                                medicine['milligram'],
                              ),
                              _buildLabeledDetail("Type", medicine['type']),
                              _buildLabeledDetail(
                                "Batch Code",
                                medicine['batch_code'],
                              ),
                              _buildLabeledDetail(
                                "Quantity",
                                medicine['quantity'].toString(),
                              ),
                              _buildLabeledDetail(
                                "Expiration",
                                medicine['expiration'],
                              ),
                              _buildLabeledDetail(
                                "Requested",
                                medicine['request_date'],
                              ),
                              const Divider(),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildLabeledDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget buildTabContent(List<Map<String, dynamic>> dataList) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dataList.isEmpty) {
      return const Center(
        child: Text(
          "No data available.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        return buildGroupCard(dataList[index]);
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBBDEFB),
      appBar: AppBar(
        title: const Text("Accepted Medicines", style: TextStyle(fontSize: 20)),
        backgroundColor: const Color(0xFFBBDEFB),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Material(
              color: Colors.white,
              elevation: 1,
              borderRadius: BorderRadius.circular(16),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF004C72),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF004C72),
                tabs: const [Tab(text: "Requested"), Tab(text: "Completed")],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildTabContent(requestedList),
          buildTabContent(completedList),
        ],
      ),
    );
  }
}
