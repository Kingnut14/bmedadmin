// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:bmedv2/screen/User_screen.dart';
// import '../screen/dashboard_screen.dart';
// import '../screen/message_screen.dart';
// // ignore: library_prefixes
// // import 'package:bmedv2/screen/user_screen.dart' as userScreen;
// import '../screen/schedule_screen.dart';
// import '../screen/ocr_medicine_scanner.dart';

// class CustomNavBar extends StatelessWidget {
//   final int selectedIndex;
//   final Function(int) onItemTapped;
//   final VoidCallback? onScanPressed;

//   const CustomNavBar({
//     required this.selectedIndex,
//     required this.onItemTapped,
//     this.onScanPressed,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDarkMode = theme.brightness == Brightness.dark;

//     final Color bgColor = isDarkMode ? Colors.black : const Color(0xFF2196F3);
//     final Color selectedColor = isDarkMode ? Colors.blue.shade300 : Colors.white;
//     final Color unselectedColor = isDarkMode ? Colors.white60 : Colors.white70;

//     final items = [
//       {'icon': FontAwesomeIcons.house, 'label': 'Home', 'screen': DashboardScreen()},
//       {'icon': FontAwesomeIcons.envelope, 'label': 'Messages', 'screen': MessagesScreen()},
//       {'icon': FontAwesomeIcons.camera, 'label': 'OCR', 'screen': OcrMedicineScanner()},
//       {'icon': FontAwesomeIcons.calendar, 'label': 'Schedule', 'screen': ScheduleScreen()},
//       {'icon': FontAwesomeIcons.users, 'label': 'User', 'screen': UserManagementScreen()},
//     ];

//     return Container(
//       color: bgColor,
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: List.generate(items.length, (index) {
//           bool isSelected = selectedIndex == index;

//           return GestureDetector(
//             onTap: () {
//               if (!isSelected) {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => items[index]['screen'] as Widget),
//                 );
//               }
//             },
//             child: Tooltip(
//               message: items[index]['label'] as String, // Tooltip message
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 250),
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: isSelected ? selectedColor.withOpacity(0.2) : Colors.transparent,
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: Row(
//                   children: [
//                     FaIcon(
//                       items[index]['icon'] as IconData,
//                       color: isSelected ? selectedColor : unselectedColor,
//                       size: 20,
//                     ),
//                     if (isSelected)
//                       Padding(
//                         padding: const EdgeInsets.only(left: 8),
//                         child: Text(
//                           items[index]['label'] as String,
//                           style: TextStyle(
//                             color: selectedColor,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
