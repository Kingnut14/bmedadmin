// settings_drawer.dart (UI redesign with background color 0xFFBBDEFB)

import 'dart:io';
import 'package:bmedv2/scanner/accepted_screen%20updated.dart';
import 'package:bmedv2/screen/most_dispensed_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../provider/font_size_provider.dart';
import '../settings/admin_profile_screen.dart';
import '../settings/announcements_screen.dart';
import 'package:image_picker/image_picker.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late ImagePicker _picker;
  XFile? _image;
  String userName = "John Doe";
  String userRole = "Admin";
  bool isDisplayExpanded = false;

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      elevation: 14,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Container(
        color: const Color(0xFFBBDEFB), // main background color
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            children: [
              // Profile Header
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade100.withOpacity(0.6),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue.shade700,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade700.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.transparent,
                          backgroundImage:
                              _image == null
                                  ? const AssetImage('assets/logo.png')
                                  : FileImage(File(_image!.path))
                                      as ImageProvider,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: TextStyle(
                                fontSize: fontSizeProvider.fontSize + 4,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              userRole,
                              style: TextStyle(
                                fontSize: fontSizeProvider.fontSize,
                                color: Colors.blueGrey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 4,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade700,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Settings Items
              _buildSettingItem(
                context,
                icon: Icons.person_outline,
                title: "Admin Profile",
                action:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdminProfileScreen()),
                    ),
                bgColor: Colors.white.withOpacity(0.9),
                iconColor: Colors.blue.shade700,
                fontSize: fontSizeProvider.fontSize,
              ),

              _buildSettingItem(
                context,
                icon: Icons.history_rounded,
                title: "History",
                action:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AcceptedScreen(token: ''),
                      ),
                    ),
                bgColor: Colors.white.withOpacity(0.9),
                iconColor: Colors.blue.shade700,
                fontSize: fontSizeProvider.fontSize,
              ),

              _buildSettingItem(
                context,
                icon: Icons.file_copy_outlined,
                title: "Dispensed Reports",
                action:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MostDispensedScreen()),
                    ),
                bgColor: Colors.white.withOpacity(0.9),
                iconColor: Colors.blue.shade700,
                fontSize: fontSizeProvider.fontSize,
              ),

              // Combined Display Settings styled like _buildSettingItem
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100.withOpacity(0.6),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  childrenPadding: const EdgeInsets.only(bottom: 16),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.display_settings_rounded,
                      color: Colors.blue.shade700,
                      size: fontSizeProvider.fontSize + 4,
                    ),
                  ),
                  title: Text(
                    "Display Settings",
                    style: TextStyle(
                      fontSize: fontSizeProvider.fontSize + 2,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: Icon(
                    isDisplayExpanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    color: Colors.blueGrey.shade400,
                    size: fontSizeProvider.fontSize + 6,
                  ),
                  onExpansionChanged: (expanded) {
                    setState(() {
                      isDisplayExpanded = expanded;
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Theme toggle
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              "Dark Mode",
                              style: TextStyle(
                                fontSize: fontSizeProvider.fontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            activeColor: Colors.blue.shade700,
                            value: isDarkMode,
                            onChanged: (value) {
                              themeProvider.toggleTheme(value);
                            },
                          ),
                          const SizedBox(height: 6),
                          Divider(
                            color: Colors.blueGrey.shade100,
                            thickness: 1,
                          ),
                          const SizedBox(height: 12),

                          // Font size
                          Text(
                            "Font Size",
                            style: TextStyle(
                              fontSize: fontSizeProvider.fontSize + 1,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                "A",
                                style: TextStyle(
                                  fontSize: fontSizeProvider.fontSize - 6,
                                  color: Colors.blueGrey.shade400,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: Colors.blue.shade700,
                                    inactiveTrackColor: Colors.blue.shade100,
                                    thumbColor: Colors.blue.shade700,
                                    overlayColor: Colors.blue.shade700
                                        .withOpacity(0.3),
                                    trackHeight: 7,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 14,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 28,
                                    ),
                                  ),
                                  child: Slider(
                                    value: fontSizeProvider.fontSize,
                                    min: 12,
                                    max: 30,
                                    divisions: 9,
                                    onChanged:
                                        (value) =>
                                            fontSizeProvider.setFontSize(value),
                                  ),
                                ),
                              ),
                              Text(
                                "A",
                                style: TextStyle(
                                  fontSize: fontSizeProvider.fontSize + 12,
                                  color: Colors.blueGrey.shade400,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Current: ${fontSizeProvider.fontSize.toInt()}",
                              style: TextStyle(
                                fontSize: fontSizeProvider.fontSize - 2,
                                color: Colors.blueGrey.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Logout button
              _buildSettingItem(
                context,
                icon: Icons.logout,
                title: "Log out",
                action: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text("Confirm Logout"),
                          content: const Text(
                            "Are you sure you want to log out?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                "Log out",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );

                  if (shouldLogout == true) {
                    // 🔒 TODO: Add backend logout logic here.
                    // Example: await AuthService.logout();

                    // Clear navigation and go to login or welcome screen
                    // Navigator.pushAndRemoveUntil(
                    //   context,
                    //   MaterialPageRoute(builder: (_) => const LoginScreen()), // Replace with your login screen
                    //   (route) => false,
                    // );
                  }
                },
                bgColor: Colors.white.withOpacity(0.9),
                iconColor: Colors.blue.shade700,
                fontSize: fontSizeProvider.fontSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback action,
    required Color bgColor,
    required Color iconColor,
    required double fontSize,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.6),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: fontSize + 4),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: fontSize + 2,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.blueGrey.shade400,
          size: fontSize,
        ),
        onTap: action,
      ),
    );
  }
}
