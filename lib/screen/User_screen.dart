import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../provider/unread_count_provider.dart';
import '../widget/custom_app_bar.dart';
// import '../widget/custom_nav_bar.dart';
// import 'dashboard_screen.dart';
// import 'message_screen.dart';
// import 'schedule_screen.dart';
// import 'ocr_medicine_scanner.dart';

class UserManagementScreen extends StatefulWidget {
  final Function (int) onTabSelected;
  const UserManagementScreen({super.key, required this.onTabSelected});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  // int _selectedIndex = 4;
  String searchQuery = '';
  String filterOption = 'All';

  final List<Map<String, String>> users = [
    {
      'first_name': 'John',
      'last_name': 'Doe',
      'age': '25',
      'sex': 'Male',
      'barangay_id': '001',
      'street': 'Main St',
      'phone_number': '09123456789',
    },
    {
      'first_name': 'Jane',
      'last_name': 'Smith',
      'age': '30',
      'sex': 'Female',
      'barangay_id': '002',
      'street': '2nd Ave',
      'phone_number': '09198765432',
    },
    {
      'first_name': 'Alice',
      'last_name': 'Johnson',
      'age': '22',
      'sex': 'Female',
      'barangay_id': '003',
      'street': '3rd Ave',
      'phone_number': '09223334455',
    },
    {
      'first_name': 'Bob',
      'last_name': 'Brown',
      'age': '40',
      'sex': 'Male',
      'barangay_id': '004',
      'street': 'Elm St',
      'phone_number': '09112223344',
    },
    {
      'first_name': 'Charlie',
      'last_name': 'Davis',
      'age': '35',
      'sex': 'Male',
      'barangay_id': '005',
      'street': 'Pine St',
      'phone_number': '09224445566',
    },
  ];

  late TextEditingController ageController;
  late TextEditingController sexController;
  late TextEditingController barangayIdController;
  late TextEditingController streetController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    ageController = TextEditingController();
    sexController = TextEditingController();
    barangayIdController = TextEditingController();
    streetController = TextEditingController();
    phoneController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose controllers when no longer needed
    ageController.dispose();
    sexController.dispose();
    barangayIdController.dispose();
    streetController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _filterUsers() {
    List<Map<String, String>> result = users.where((user) {
      final name = '${user['first_name']} ${user['last_name']}'.toLowerCase();
      final matchesQuery = user['barangay_id']!.toLowerCase().contains(
          searchQuery.toLowerCase()) ||
          name.contains(searchQuery.toLowerCase());

      if (filterOption == 'Male' || filterOption == 'Female') {
        return matchesQuery && user['sex'] == filterOption;
      }
      return matchesQuery;
    }).toList();

    if (filterOption == 'Youngest') {
      result.sort((a, b) =>
          int.parse(a['age']!).compareTo(int.parse(b['age']!)));
    } else if (filterOption == 'Oldest') {
      result.sort((a, b) =>
          int.parse(b['age']!).compareTo(int.parse(a['age']!)));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;
    final unreadCount = Provider
        .of<UnreadCountProvider>(context)
        .unreadCount;

    final List<Map<String, String>> filteredUsers = _filterUsers();

    return Scaffold(
      appBar: CustomAppBar(
        title: "User Management",
        fontSize: 15,
        isDarkMode: isDarkMode,
      ),
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchAndSortRow(isDarkMode),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _showUserDetailsOverlay(filteredUsers[index]);
                    },
                    child: _buildUserCard(filteredUsers[index], isDarkMode),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: CustomNavBar(
      //   selectedIndex: _selectedIndex,
      //   onItemTapped: (index) {
      //     setState(() {
      //       _selectedIndex = index;
      //     });

      //     final screens = [
      //       DashboardScreen(),
      //       MessagesScreen(),
      //       OcrMedicineScanner(),
      //       ScheduleScreen(),
      //       UserManagementScreen(),
      //     ];

      //     if (index < screens.length) {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (_) => screens[index]),
      //       );
      //     }
      //   },
      // ),
    );
  }

  Widget _buildSearchAndSortRow(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list,
                color: isDarkMode ? Colors.white : Colors.black),
            onSelected: (value) {
              setState(() {
                filterOption = value;
              });
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<String>(
                    value: 'Youngest', child: Text('Youngest')),
                PopupMenuItem<String>(value: 'Oldest', child: Text('Oldest')),
                PopupMenuItem<String>(value: 'Male', child: Text('Male')),
                PopupMenuItem<String>(value: 'Female', child: Text('Female')),
                PopupMenuItem<String>(value: 'All', child: Text('All')),
              ];
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, String> user, bool isDarkMode) {
    return Card(
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 16),
      shadowColor: Colors.blue.shade900,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user['first_name']} ${user['last_name']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Street: ${user['street']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.info_outline,
                color: isDarkMode ? Colors.white : Colors.black),
          ],
        ),
      ),
    );
  }

  void _showUserDetailsOverlay(Map<String, String> user) {
    ageController.text = user['age'] ?? '';
    sexController.text = user['sex'] ?? '';
    barangayIdController.text = user['barangay_id'] ?? '';
    streetController.text = user['street'] ?? '';
    phoneController.text = user['phone_number'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Material(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              elevation: 10,
              child: Stack(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery
                          .of(context)
                          .size
                          .height * 1.8,
                      maxWidth: MediaQuery
                          .of(context)
                          .size
                          .width * 1.9,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            Center(
                              child: CircleAvatar(
                                radius: 60,
                                child: const Icon(Icons.person, size: 70,
                                    color: Colors.white),
                                backgroundColor: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: Text(
                                '${user['first_name']} ${user['last_name']}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(child: _buildTextField(
                                    'Age', ageController, Icons.calendar_today,
                                    theme)),
                                const SizedBox(width: 12),
                                Expanded(child: _buildTextField(
                                    'Sex', sexController, Icons.transgender,
                                    theme)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTextField('Brgy ID', barangayIdController,
                                Icons.location_on, theme),
                            const SizedBox(height: 12),
                            _buildTextField(
                                'Street', streetController, Icons.streetview,
                                theme),
                            const SizedBox(height: 12),
                            _buildTextField(
                                'Phone Number', phoneController, Icons.phone,
                                theme),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.close, color: theme.iconTheme.color),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      IconData icon, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      readOnly: true, // Ensures the text field is read-only
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black, // Text color
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black, // Label text color
        ),
        prefixIcon: Icon(icon, color: isDark ? Colors.white : Colors.black),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.white, // Background color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}