import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../provider/unread_count_provider.dart';
import '../provider/font_size_provider.dart'; // Import your font size provider
import '../widget/custom_app_bar.dart';

class AcceptedScreen extends StatefulWidget {
  final List<Map<String, String>> parsedRequests;

  const AcceptedScreen({
    super.key,
    required this.parsedRequests,
  });

  @override
  State<AcceptedScreen> createState() => _AcceptedScreenState();
}

class _AcceptedScreenState extends State<AcceptedScreen> {
  String? selectedName;
  late List<Map<String, String>> requests;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    requests = widget.parsedRequests.isNotEmpty
        ? widget.parsedRequests
        : [
      {
        "name": "Juan Dela Cruz",
        "Medicine Name": "Paracetamol",
        "Dosage": "500mg",
        "Type": "Tablet",
        "Quantity": "20",
        "Notes": "Take after meal",
      },
      {
        "name": "Juan Dela Cruz",
        "Medicine Name": "Cough Syrup",
        "Dosage": "10ml",
        "Type": "Syrup",
        "Quantity": "1 bottle",
        "Notes": "Twice a day",
      },
      {
        "name": "Juan Dela Cruz",
        "Medicine Name": "Amoxicillin",
        "Dosage": "250mg",
        "Type": "Capsule",
        "Quantity": "30",
        "Notes": "Every 8 hours",
      },
      {
        "name": "Maria Clara",
        "Medicine Name": "Ibuprofen",
        "Dosage": "200mg",
        "Type": "Capsule",
        "Quantity": "10",
        "Notes": "For headache",
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final unreadCount = Provider.of<UnreadCountProvider>(context).unreadCount;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSize = Provider.of<FontSizeProvider>(context).fontSize;

    final groupedRequests = <String, List<Map<String, String>>>{};
    for (var request in requests) {
      final name = request['name'] ?? "Unknown";
      groupedRequests.putIfAbsent(name, () => []).add(request);
    }

    final filteredNames = groupedRequests.keys
        .where((name) => name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: CustomAppBar(
        title: "User Management",
        fontSize: fontSize + 2,
        isDarkMode: themeProvider.isDarkMode,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            GestureDetector(
              onTap: () {
                if (selectedName != null) {
                  setState(() => selectedName = null);
                } else {
                  Navigator.pop(context);
                }
              },
              child: Row(
                children: [
                  Icon(Icons.arrow_back_ios_new, color: Theme.of(context).iconTheme.color),
                  const SizedBox(width: 8),
                  Text(
                    "Back",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🔍 Search Bar
            TextField(
              style: TextStyle(fontSize: fontSize),
              decoration: InputDecoration(
                hintText: "Search by name...",
                hintStyle: TextStyle(fontSize: fontSize),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  selectedName = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Name list
            if (filteredNames.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredNames.length,
                itemBuilder: (context, index) {
                  final name = filteredNames[index];
                  final isSelected = selectedName == name;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedName = isSelected ? null : name;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? Colors.blue.shade700 : Colors.blue.shade200)
                            : (isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFFFFFF)),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade900,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: fontSize,
                              color: isSelected
                                  ? (isDark ? Colors.white : Colors.blue.shade900)
                                  : (isDark ? Colors.grey[300] : Colors.blue.shade700),
                            ),
                          ),
                          Icon(
                            isSelected ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                            color: isSelected
                                ? (isDark ? Colors.white : Colors.blue.shade900)
                                : (isDark ? Colors.grey[300] : Colors.blue.shade700),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Text(
                    "No matching names found.",
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Show request details
            if (selectedName != null)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedName!,
                      style: TextStyle(
                        fontSize: fontSize + 6,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const Divider(thickness: 1.2, height: 24),
                    if (groupedRequests[selectedName]!.isNotEmpty)
                      ...groupedRequests[selectedName]!.asMap().entries.map((entry) {
                        final requestIndex = entry.key + 1;
                        final request = entry.value;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Request #$requestIndex",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: fontSize,
                                      color: isDark ? Colors.white : Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...request.entries
                                      .where((e) => e.key != "name" && e.value.trim().isNotEmpty)
                                      .map((e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 20,
                                          color: isDark ? Colors.white : Colors.blue,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "${e.key}: ${e.value}",
                                            style: TextStyle(
                                              fontSize: fontSize - 2,
                                              color: isDark ? Colors.grey[300] : Colors.black,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                                      .toList(),
                                ],
                              ),
                            ),
                          ),
                        );
                      })
                    else
                      Text(
                        "No requests available for $selectedName.",
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: fontSize,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
