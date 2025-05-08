import 'package:bmedv2/screen/User_screen.dart';
import 'package:bmedv2/screen/dashboard_screen.dart';
import 'package:bmedv2/screen/message_screen.dart';
import 'package:bmedv2/screen/ocr_medicine_scanner.dart';
import 'package:bmedv2/screen/schedule_screen.dart';
import 'package:flutter/material.dart';

import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Default to the first tab
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  // Initialize the list of pages
  void _initializePages() {
    _pages = [
      DashboardScreen(onTabSelected: _onTabSelected),
      OcrMedicineScanner(onTabSelected: _onTabSelected),
      ScheduleScreen(onTabSelected: _onTabSelected),
      UserManagementScreen(onTabSelected: _onTabSelected),

      // qrcodescreen(qrData: 'Sample QR Code Data', onTabSelected: _onTabSelected),
    ];
  }

  // Handle tab selection
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Define bottom bar items
  List<SalomonBottomBarItem> _bottomBarItems() {
    return [
      SalomonBottomBarItem(
        icon: const Icon(Icons.dashboard),
        title: const Text("Dashboard"),
        selectedColor: Colors.blue,
      ),
      SalomonBottomBarItem(
        icon: const Icon(Icons.camera_alt),
        title: const Text("OCR"),
        selectedColor: Colors.blue,
      ),
            SalomonBottomBarItem(
        icon: const Icon(Icons.schedule),
        title: const Text("Schedule"),
        selectedColor: Colors.blue,
      ),
            SalomonBottomBarItem(
        icon: const Icon(Icons.people),
        title: const Text("User"),
        selectedColor: Colors.blue,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _bottomBarItems(),
      ),
    );
  }
}