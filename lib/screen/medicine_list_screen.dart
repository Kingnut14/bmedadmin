import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../provider/unread_count_provider.dart';
import '../widget/custom_app_bar.dart';
// import '../widget/custom_nav_bar.dart';
// import 'dashboard_screen.dart';
// import 'message_screen.dart';
// import 'ocr_medicine_scanner.dart';
// import 'schedule_screen.dart';
// import '../screen/user_screen.dart';

class MedicineListScreen extends StatefulWidget {
  final List<Map<String, String>>? medicineList;

  const MedicineListScreen({super.key, this.medicineList});

  @override
  _MedicineListScreenState createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  late List<Map<String, String>> medicineList;
  final ImagePicker _picker = ImagePicker();
  // int _selectedIndex = -1; // Track the selected index for the CustomNavBar

  @override
  void initState() {
    super.initState();
    medicineList = widget.medicineList?.isNotEmpty == true
        ? widget.medicineList!
        : [
      {
        'Medicine Name': 'Paracetamol Extra Strength',
        'Brand Name': 'Biogesic Max',
        'Dosage': '500mg',
        'Type of Medicine': 'Tablet',
        'Stocks': '100',
        'Expiration Date': '2025-06-30',
        'Image Path': '',
      },
      {
        'Medicine Name': 'Ibuprofen Long Lasting Relief',
        'Brand Name': 'Advil Extended Release',
        'Dosage': '200mg',
        'Type of Medicine': 'Capsule',
        'Stocks': '50',
        'Expiration Date': '2024-12-01',
        'Image Path': '',
      },
      {
        'Medicine Name': 'Cough Syrup for Dry and Wet Cough',
        'Brand Name': 'Solmux Advance',
        'Dosage': 'N/A',
        'Type of Medicine': 'Syrup',
        'Stocks': '30',
        'Expiration Date': '2026-03-15',
        'Image Path': '',
      },
      {
        'Medicine Name': 'Another Long Name Medicine',
        'Brand Name': 'Generic Brand Very Long Name',
        'Dosage': '10mg',
        'Type of Medicine': 'Pill',
        'Stocks': '200',
        'Expiration Date': '2027-01-01',
        'Image Path': '',
      },
    ];
  }

  String getValue(String? value) {
    return (value != null && value.isNotEmpty) ? value : 'Not Available';
  }

  Future<void> _pickImage(int index) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          medicineList[index]['Image Path'] = pickedFile.path;
        });
      } else {
        print("User cancelled image picking");
      }
    } catch (e) {
      print('Error picking image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to pick image. Please try again.'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // void _onNavItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });

  //   // Handle navigation for different screens based on index
  //   switch (index) {
  //     case 0:
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => DashboardScreen(onTabSelected: (int ) {  },)),
  //       );
  //       break;
  //     case 1:
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => MessagesScreen(onTabSelected: (int ) {  },)),
  //       );
  //       break;
  //     case 2:
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => OcrMedicineScanner(onTabSelected: (int ) {  },)),
  //       );
  //       break;
  //     case 3:
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => ScheduleScreen(onTabSelected: (int ) {  },)),
  //       );
  //       break;
  //     case 4:
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => UserManagementScreen()),
  //       );
  //       break;
  //     default:
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _ = theme.brightness == Brightness.dark;
    final unreadCount = Provider.of<UnreadCountProvider>(context).unreadCount;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Medicine List',
        fontSize: 15,
        isDarkMode: theme.brightness == Brightness.dark,
      ),
      // The rest of your Scaffold code here

    body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => Navigator.pop(context), // Back action
                ),
                const Text(
                  '',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 15,
              ),
              itemCount: medicineList.length,
              itemBuilder: (context, index) {
                final medicine = medicineList[index];
                final imagePath = medicine['Image Path'] ?? '';

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: () => _pickImage(index),
                        child: Container(
                          height: 104.7,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                            color: Colors.grey[200],
                            image: imagePath.isNotEmpty
                                ? DecorationImage(
                              image: FileImage(File(imagePath)),
                              fit: BoxFit.contain,
                            )
                                : const DecorationImage(
                              image: AssetImage('assets/placeholder_medicine.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 1.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(
                          getValue(medicine['Medicine Name']),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.3),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 1.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(
                          getValue(medicine['Brand Name']),
                          style: const TextStyle(fontSize: 9.3, color: Colors.grey),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(flex: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.7, vertical: 3.7),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 3.7, vertical: 1.7),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 1,
                            textStyle: const TextStyle(fontSize: 8.7),
                          ),
                          icon: const Icon(Icons.shopping_cart, size: 9.7),
                          label: const Text("Add", style: TextStyle(fontSize: 8.7)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${getValue(medicine['Medicine Name'])} added!"),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // bottomNavigationBar: CustomNavBar(
      //   selectedIndex: _selectedIndex,
      //   onItemTapped: _onNavItemTapped,
      // ),
    );
  }
}
