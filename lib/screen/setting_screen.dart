import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../provider/font_size_provider.dart';
import '../settings/admin_profile_screen.dart';
import '../settings/announcements_screen.dart'; // Import the new AnnouncementsScreen
import 'package:image_picker/image_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ImagePicker _picker;
  XFile? _image;
  String userName = "John Doe";
  String userRole = "Admin";

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(fontSize: fontSizeProvider.fontSize),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: _image == null
                        ? const AssetImage('assets/logo.png') // Default image
                        : FileImage(File(_image!.path)), // Selected image
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: fontSizeProvider.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userRole,
                        style: TextStyle(
                          fontSize: fontSizeProvider.fontSize,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: _pickImage,
            ),
            const Divider(),

            // Admin Profile ListTile
            ListTile(
              title: Text(
                "Admin Profile",
                style: TextStyle(fontSize: fontSizeProvider.fontSize),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminProfileScreen()),
                );
              },
              trailing: const Icon(Icons.verified_user, color: Colors.blue),
            ),

            const Divider(),

            // Announcements ListTile (navigate to AnnouncementsScreen)
            ListTile(
              title: Text(
                "Announcements",
                style: TextStyle(fontSize: fontSizeProvider.fontSize),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnnounceScreen()),
                );
              },
              trailing: const Icon(Icons.notifications, color: Colors.blue),
            ),

            const Divider(),

            // Change Theme ListTile
            ListTile(
              title: Text(
                "Change Theme",
                style: TextStyle(fontSize: fontSizeProvider.fontSize),
              ),
              onTap: () {
                themeProvider.toggleTheme(!themeProvider.isDarkMode);
              },
              trailing: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
            ),

            // Font Size ListTile
            ListTile(
              title: Text(
                "Font Size",
                style: TextStyle(fontSize: fontSizeProvider.fontSize),
              ),
              subtitle: Text(
                "Current: ${fontSizeProvider.fontSize.toInt()}",
                style: TextStyle(fontSize: fontSizeProvider.fontSize),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                    onPressed: () {
                      if (fontSizeProvider.fontSize > 12) {
                        fontSizeProvider.setFontSize(fontSizeProvider.fontSize - 2);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                    onPressed: () {
                      if (fontSizeProvider.fontSize < 30) {
                        fontSizeProvider.setFontSize(fontSizeProvider.fontSize + 2);
                      }
                    },
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
