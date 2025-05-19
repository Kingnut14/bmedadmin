import 'dart:convert';
import 'package:bmedv2/screen/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../provider/unread_count_provider.dart';
import '../widget/custom_app_bar.dart';

class UserManagementScreen extends StatefulWidget {
  final Function(int) onTabSelected;
  const UserManagementScreen({super.key, required this.onTabSelected});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String searchQuery = '';
  String filterOption = 'All';

  List<Map<String, String>> users = [];

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
    _fetchUsers();
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

  // Function to fetch users from the backend API
  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5566/users'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['retCode'] == "200" && data['data'] != null) {
          final List<Map<String, String>> loadedUsers = [];

          for (var user in data['data']) {
            loadedUsers.add({
              'first_name': user['first_name'].toString(),
              'last_name': user['last_name'].toString(),
              'age': user['age'].toString(),
              'sex': user['sex'].toString(),
              'brgy_id': user['brgy_id'].toString(),
              'street': user['street'].toString(),
              'phone_number': user['phone_number'].toString(),
            });
          }

          setState(() {
            users = loadedUsers;
          });
        } else {
          _showErrorDialog('No users found.');
        }
      } else {
        _showErrorDialog(
          'Failed to fetch users. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _showErrorDialog('An error occurred: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<Map<String, String>> _filterUsers() {
    List<Map<String, String>> result =
        users.where((user) {
          final name =
              '${user['first_name']} ${user['last_name']}'.toLowerCase();
          final matchesQuery =
              user['brgy_id']!.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              name.contains(searchQuery.toLowerCase());

          if (filterOption == 'Male' || filterOption == 'Female') {
            return matchesQuery && user['sex'] == filterOption;
          }
          return matchesQuery;
        }).toList();

    if (filterOption == 'Youngest') {
      result.sort(
        (a, b) => int.parse(a['age']!).compareTo(int.parse(b['age']!)),
      );
    } else if (filterOption == 'Oldest') {
      result.sort(
        (a, b) => int.parse(b['age']!).compareTo(int.parse(a['age']!)),
      );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;
    final unreadCount = Provider.of<UnreadCountProvider>(context).unreadCount;

    final List<Map<String, String>> filteredUsers = _filterUsers();

    return Scaffold(
      appBar: CustomAppBar(
        title: "User Management",
        fontSize: 15,
        isDarkMode: isDarkMode,
      ),
      drawer: const MenuScreen(),
      backgroundColor: isDarkMode ? Colors.black : Color(0xFFBBDEFB),
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
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.filter_list,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onSelected: (value) {
              setState(() {
                filterOption = value;
              });
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<String>(
                  value: 'Youngest',
                  child: Text('Youngest'),
                ),
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
            Icon(
              Icons.info_outline,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetailsOverlay(Map<String, String> user) {
    ageController.text = user['age'] ?? '';
    sexController.text = user['sex'] ?? '';
    barangayIdController.text = user['brgy_id'] ?? '';
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
                      maxHeight: MediaQuery.of(context).size.height * 1.8,
                      maxWidth: MediaQuery.of(context).size.width * 1.9,
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
                                child: const Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.white,
                                ),
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
                                Expanded(
                                  child: _buildTextField(
                                    'Age',
                                    ageController,
                                    Icons.calendar_today,
                                    theme,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    'Sex',
                                    sexController,
                                    Icons.transgender,
                                    theme,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Barangay',
                              barangayIdController,
                              Icons.home,
                              theme,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Street',
                              streetController,
                              Icons.streetview,
                              theme,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Phone',
                              phoneController,
                              Icons.phone,
                              theme,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.black,
                      ),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    ThemeData theme,
  ) {
    return TextField(
      controller: controller,
      enabled: false,
      decoration: InputDecoration(
        icon: Icon(icon, color: theme.iconTheme.color),
        labelText: label,
        labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.disabledColor),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: theme.disabledColor.withOpacity(0.1),
      ),
    );
  }
}
