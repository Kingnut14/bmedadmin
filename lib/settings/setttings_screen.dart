// import 'package:flutter/material.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Settings",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
//         ),
//         backgroundColor: Colors.blueAccent,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
//         child: ListView(
//           children: [
//             // General Settings
//             _buildSectionTitle('General Settings'),
//             SizedBox(height: 10),
//             _buildCard(
//               child: Column(
//                 children: [
//                   _buildSwitchTile('Enable Notifications', true, (bool value) {
//                     // Implement logic to handle the switch value
//                   }),
//                   Divider(),
//                   _buildListTile('Language', 'English', () {}),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),

//             // Account Settings
//             _buildSectionTitle('Account Settings'),
//             SizedBox(height: 10),
//             _buildCard(
//               child: Column(
//                 children: [
//                   _buildListTile('Change Password', 'Update your password', () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
//                     );
//                   }),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.w600,
//         color: Colors.blueAccent,
//       ),
//     );
//   }

//   Widget _buildCard({required Widget child}) {
//     return Card(
//       elevation: 5,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: child,
//       ),
//     );
//   }

//   Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
//     return SwitchListTile(
//       contentPadding: EdgeInsets.zero,
//       title: Text(
//         title,
//         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//       ),
//       value: value,
//       onChanged: onChanged,
//       activeColor: Colors.blueAccent,
//     );
//   }

//   Widget _buildListTile(String title, String subtitle, Function() onTap) {
//     return ListTile(
//       title: Text(
//         title,
//         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: TextStyle(fontSize: 14, color: Colors.grey),
//       ),
//       trailing: Icon(Icons.arrow_forward_ios, size: 16),
//       onTap: onTap,
//     );
//   }
// }

// class ChangePasswordScreen extends StatefulWidget {
//   @override
//   _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
// }

// class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();
//   String errorMessage = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Change Password'),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: passwordController,
//               obscureText: true,
//               decoration: InputDecoration(
//                 labelText: 'Enter new password',
//                 errorText: errorMessage.isEmpty ? null : errorMessage,
//               ),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: confirmPasswordController,
//               obscureText: true,
//               decoration: InputDecoration(labelText: 'Confirm new password'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 if (passwordController.text == confirmPasswordController.text) {
//                   // Save the password logic here
//                   Navigator.pop(context);  // Close the Change Password screen
//                 } else {
//                   setState(() {
//                     errorMessage = 'Passwords do not match';
//                   });
//                 }
//               },
//               child: Text('Update Password'),
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
