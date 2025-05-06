import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController fullNameController = TextEditingController(text: "BARA MED");
  TextEditingController phoneNumberController = TextEditingController(text: "09123456789");
  TextEditingController emailController = TextEditingController(text: "baramed@example.com");
  TextEditingController dateOfBirthController = TextEditingController(text: "DD / MM /${String.fromCharCode(0x1F5D3)}");

  bool _isEditing = false;

  @override
  void dispose() {
    fullNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    dateOfBirthController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    setState(() {
      fullName = fullNameController.text;
      phoneNumber = phoneNumberController.text;
      email = emailController.text;
      dateOfBirth = dateOfBirthController.text;
      _isEditing = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    });
  }

  String fullName = "BARA MED";
  String phoneNumber = "09123456789";
  String email = "baramed@example.com";
  String dateOfBirth = "DD / MM /${String.fromCharCode(0x1F5D3)}";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final inputFieldColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final accentColor = Colors.blueAccent; // Modern blue color

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: accentColor,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text("Profile", style: TextStyle(color: accentColor)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            color: accentColor,
            onPressed: _isEditing ? _saveChanges : _toggleEdit,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            color: accentColor,
            onPressed: () {
              // Handle settings action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: const AssetImage('assets/logo.png'), // Replace with your actual asset path
                    backgroundColor: Colors.grey.shade300,
                  ),
                  if (_isEditing)
                    Container(
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: backgroundColor, width: 2),
                      ),
                      padding: const EdgeInsets.all(6.0),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildProfileTextField("Full Name", fullNameController, inputFieldColor, textColor, _isEditing),
            _buildProfileTextField("Phone Number", phoneNumberController, inputFieldColor, textColor, _isEditing),
            _buildProfileTextField("Email", emailController, inputFieldColor, textColor, _isEditing),
            _buildProfileTextField("Date Of Birth", dateOfBirthController, inputFieldColor, textColor, _isEditing),

            const SizedBox(height: 40),
            if (!_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _toggleEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Edit Profile", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Indicate save action
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Save Changes", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTextField(
      String label,
      TextEditingController controller,
      Color inputColor,
      Color textColor,
      bool isEditable,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor.withOpacity(0.7)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: isEditable,
            style: TextStyle(fontSize: 16, color: textColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: inputColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            ),
          ),
        ],
      ),
    );
  }
}
