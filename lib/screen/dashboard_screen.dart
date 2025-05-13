import 'package:bmedv2/scanner/accepted_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../provider/theme_provider.dart';
import '../provider/font_size_provider.dart';
import '../provider/unread_count_provider.dart';
// import '../widget/custom_nav_bar.dart';
import 'medicine_list_screen.dart';
import '../widget/custom_app_bar.dart';
import 'most_dispensed_screen.dart';
// import '../widget/bottombar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bmedv2/scanner/qr_scanner_screen.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  final Function(int) onTabSelected;
  const DashboardScreen({super.key, required this.onTabSelected});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _selectedDay = DateTime.now();
  List<Map<String, String>> medicines = [];
  List<Map<String, String>> mostDispensedMedicine = [];
  List<Map<String, dynamic>> backendSchedules = [];
  Timer? _refreshTimer;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMedicinesData();
    _startAutoRefresh(); // 🔹 Add this line
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // 🔹 Prevent memory leaks
    super.dispose();
  }

  // Fetch medicines data from the backend
  Future<void> _fetchMedicinesData() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:5566/dashboard'),
    );

    //print(response.body);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final data = decoded['data'] ?? {};

      List<dynamic> availableMedicines = data['available_medicines'] ?? [];
      List<dynamic> mostDispensedMedicines =
          data['most_dispensed_medicines'] ?? [];
      List<dynamic> schedules = data['schedules'] ?? [];

      //print("Most Dispensed Medicines: $mostDispensedMedicines");

      // Update your medicines list accordingly
      setState(() {
        medicines =
            availableMedicines
                .map(
                  (item) => {
                    'name': item['medicine_name']?.toString() ?? '',
                    'quantity': item['stock']?.toString() ?? '0',
                  },
                )
                .toList()
                .cast<Map<String, String>>();

        backendSchedules =
            schedules
                .map<Map<String, dynamic>>(
                  (item) => {
                    'event': item['event'],
                    'description': item['description'],
                    'location': item['location'],
                    'start_time': item['start_time'],
                    'end_time': item['end_time'],
                    'date': item['date'],
                  },
                )
                .toList();

        mostDispensedMedicine =
            mostDispensedMedicines
                .map<Map<String, String>>(
                  (item) => {
                    'medicine_name': item['medicine_name'] ?? '',
                    'total_quantity': item['total_quantity']?.toString() ?? '0',
                  },
                )
                .toList();

        isLoading = false;
      });
    } else {
      throw Exception('Failed to load medicines');
    }
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _fetchMedicinesData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSize = Provider.of<FontSizeProvider>(context).fontSize;
    final unreadCount = Provider.of<UnreadCountProvider>(context).unreadCount;

    double screenWidth = MediaQuery.of(context).size.width;
    double scaledFontSize = fontSize + (screenWidth / 375);

    String appBarTitle = "Baramed";
    if (ModalRoute.of(context)?.settings.name == '/messageScreen') {
      appBarTitle = "Messages";
    } else if (ModalRoute.of(context)?.settings.name == '/dashboard') {
      appBarTitle = "Dashboard";
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: appBarTitle,
        fontSize: scaledFontSize,
        isDarkMode: themeProvider.isDarkMode,
      ),
      backgroundColor:
          themeProvider.isDarkMode ? Colors.black : const Color(0xFF94C4ED),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildTotalMedicines(
                    themeProvider,
                    scaledFontSize,
                    screenWidth,
                  ),
              _buildUpcomingSchedule(themeProvider, scaledFontSize),
              _buildTwoColumnLayout(themeProvider, scaledFontSize, screenWidth),
              _buildMostDispensedMedicines(themeProvider, scaledFontSize),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ModernQRScanner()),
          );
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.qr_code_scanner, color: Colors.blue),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Total Medicines Section
  Widget _buildTotalMedicines(
    ThemeProvider themeProvider,
    double fontSize,
    double screenWidth,
  ) {
    int totalQuantity = 0;
    List<PieChartSectionData> sections = [];
    List<Color> customColors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.yellow,
      Colors.indigo, // Added Indigo color
      Colors.teal, // Added Teal color
      Colors.brown, // Added Brown color
      Colors.grey, // Added Grey color
      Colors.amber, // Added Amber color
      Colors.lime, // Added Lime color
      Colors.pink, // Added Pink color
      Colors.deepPurple, // Added DeepPurple color
      Colors.deepOrange, // Added DeepOrange color
    ];

    if (medicines.isNotEmpty) {
      medicines.sort(
        (a, b) =>
            int.parse(b['quantity']!).compareTo(int.parse(a['quantity']!)),
      );

      List<Map<String, String>> topMedicines = medicines.take(10).toList();
      List<Map<String, String>> otherMedicines = medicines.skip(10).toList();

      totalQuantity = medicines.fold(
        0,
        (sum, med) => sum + int.parse(med['quantity']!),
      );

      for (int i = 0; i < topMedicines.length; i++) {
        int quantity = int.parse(topMedicines[i]['quantity']!);
        double percentage = (quantity / totalQuantity) * 100;

        sections.add(
          PieChartSectionData(
            value: quantity.toDouble(),
            title: "${percentage.toStringAsFixed(1)}%",
            radius: medicines.length > 10 ? 50 : 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            color: customColors[i % customColors.length],
          ),
        );
      }

      if (otherMedicines.isNotEmpty) {
        int otherQuantity = otherMedicines.fold(
          0,
          (sum, med) => sum + int.parse(med['quantity']!),
        );
        double percentage = (otherQuantity / totalQuantity) * 100;

        sections.add(
          PieChartSectionData(
            value: otherQuantity.toDouble(),
            title: "${percentage.toStringAsFixed(1)}%",
            radius: medicines.length > 10 ? 50 : 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            color: Colors.grey,
          ),
        );
      }
    } else {
      // If no data, show a single grey section with 100%
      sections.add(
        PieChartSectionData(
          value: 1, // dummy value to render the pie chart
          title: "0%",
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          color: Colors.grey.shade400,
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            themeProvider.isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900,
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Medicines",
            style: TextStyle(
              fontSize: fontSize + 4,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
                Text(
                  medicines.isEmpty ? "No data" : "$totalQuantity ",
                  style: TextStyle(
                    fontSize: fontSize + 3,
                    fontWeight: FontWeight.bold,
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Breakdown:",
            style: TextStyle(
              fontSize: fontSize + 2,
              fontWeight: FontWeight.w600,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          medicines.isEmpty
              ? Text(
                "No data available",
                style: TextStyle(
                  fontSize: fontSize,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.black87,
                ),
              )
              : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: medicines.length,
                itemBuilder: (context, index) {
                  final medicine = medicines[index];
                  Color color =
                      (index < 10)
                          ? customColors[index % customColors.length]
                          : Colors.grey;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(medicine['name']!),
                              content: Text(
                                "Quantity: ${medicine['quantity']} ",
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                medicine['name']!,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  color:
                                      themeProvider.isDarkMode
                                          ? Colors.white70
                                          : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "${medicine['quantity']} pcs",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  // UPCOMING SCHEDULE SECTION
  Widget _buildUpcomingSchedule(ThemeProvider themeProvider, double fontSize) {
    final isDark = themeProvider.isDarkMode;
    final backgroundColor =
        isDark ? const Color(0xFF1A1A2E) : const Color(0xFFE6F1F8);
    final cardColor = isDark ? const Color(0xFF2D2D3A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final fadedTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    List<Map<String, dynamic>> allSchedules = backendSchedules;

    List<Map<String, dynamic>> schedules =
        allSchedules.where((schedule) {
            // Parse the date string into DateTime before using isAfter
            final scheduleDate = DateTime.parse(schedule["date"]);
            return scheduleDate.isAfter(
              DateTime.now().subtract(const Duration(days: 1)),
            );
          }).toList()
          ..sort((a, b) {
            final dateA = DateTime.parse(a["date"]);
            final dateB = DateTime.parse(b["date"]);
            return dateA.compareTo(dateB);
          });

    List<DateTime> weekDays = List.generate(7, (index) {
      final today = DateTime.now();
      return today.subtract(Duration(days: today.weekday - 1 - index));
    });

    bool isSameDay(DateTime d1, DateTime d2) {
      return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
    }

    List<Map<String, String>> getEventsForDay(DateTime day) {
      return schedules
          .where((schedule) => isSameDay(DateTime.parse(schedule["date"]), day))
          .map(
            (schedule) => {
              "event": schedule["event"].toString(),
              "description": schedule["description"].toString(),
            },
          )
          .toList();
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.blue,
                  blurRadius: 8,
                  offset: const Offset(0, 6),
                ),
              ],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Material(
              elevation: 0,
              color: backgroundColor,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Real-time Upcoming Schedule with dynamic month
                    Text(
                      " ${DateFormat.MMMM().format(DateTime.now())}",
                      style: TextStyle(
                        fontSize: fontSize + 2,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Week day selector in a rounded white card
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                            weekDays.map((date) {
                              final isSelected = isSameDay(date, _selectedDay);
                              return Expanded(
                                child: GestureDetector(
                                  onTap:
                                      () => setState(() => _selectedDay = date),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.blue,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow:
                                          isSelected
                                              ? [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                              : [],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          DateFormat.d().format(date),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                isSelected
                                                    ? Colors.black
                                                    : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat.E()
                                              .format(date)
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                isSelected
                                                    ? Colors.black54
                                                    : Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Events of the selected day
                    Builder(
                      builder: (context) {
                        final events = getEventsForDay(_selectedDay);
                        return events.isNotEmpty
                            ? Column(
                              children:
                                  events.map((event) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 6,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            FeatherIcons.clock,
                                            size: 20,
                                            color: Colors.blue[700],
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  event['event']!,
                                                  style: TextStyle(
                                                    fontSize: fontSize,
                                                    fontWeight: FontWeight.bold,
                                                    color: textColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  event['description']!,
                                                  style: TextStyle(
                                                    fontSize: fontSize - 2,
                                                    color: fadedTextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                            )
                            : Center(
                              child: Text(
                                'No events for this day.',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  color: fadedTextColor,
                                ),
                              ),
                            );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Scrollable Upcoming events
                    Text(
                      "All Upcoming Events",
                      style: TextStyle(
                        fontSize: fontSize + 2,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Scrollable list for all events
                    SizedBox(
                      height: 200,
                      child: SingleChildScrollView(
                        child: Column(
                          children:
                              schedules.map((event) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        FeatherIcons.calendar,
                                        size: 20,
                                        color: Colors.blue[700],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateFormat.yMMMMd().format(
                                                DateTime.parse(event['date']),
                                              ),
                                              style: TextStyle(
                                                fontSize: fontSize - 1,
                                                fontWeight: FontWeight.bold,
                                                color: textColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              event['event'],
                                              style: TextStyle(
                                                fontSize: fontSize,
                                                fontWeight: FontWeight.w600,
                                                color: textColor,
                                              ),
                                            ),
                                            Text(
                                              event['description'],
                                              style: TextStyle(
                                                fontSize: fontSize - 2,
                                                color: fadedTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Two Column Layout
  Widget _buildTwoColumnLayout(
    ThemeProvider themeProvider,
    double fontSize,
    double screenWidth,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // First button: Medicine Request
              Expanded(
                child: _buildQuickActionButton(
                  themeProvider,
                  fontSize,
                  'Request',
                  Icons.note_add_outlined,
                  AcceptedScreen(parsedRequests: []),
                ),
              ),
              const SizedBox(width: 20),
              // Second button: Medicine List
              Expanded(
                child: _buildQuickActionButton(
                  themeProvider,
                  fontSize,
                  'Medicine List',
                  Icons.medical_services,
                  MedicineListScreen(medicineList: []),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Third button: Dispensed
              Expanded(
                child: _buildQuickActionButton(
                  themeProvider,
                  fontSize,
                  'Dispensed',
                  Icons.local_pharmacy_outlined,
                  MostDispensedScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    ThemeProvider themeProvider,
    double fontSize,
    String label,
    IconData icon,
    Widget destinationScreen,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationScreen),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color:
              themeProvider.isDarkMode
                  ? Colors.grey[900]
                  : Colors.blue.shade300,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade900,
              blurRadius: 10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: themeProvider.primaryColor),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: themeProvider.textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Most Dispensed Medicines Section
  Widget _buildMostDispensedMedicines(
    ThemeProvider themeProvider,
    double fontSize,
  ) {
    final bool isDark = themeProvider.isDarkMode;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color bgColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final Color dividerColor = isDark ? Colors.white12 : Colors.grey.shade200;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade900,
                  blurRadius: 8,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Row(
                        children: [
                          Icon(
                            FeatherIcons.activity,
                            color: isDark ? Colors.cyanAccent : Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Most Dispensed Medicines",
                              style: TextStyle(
                                fontSize: fontSize + 2,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Medicine List
                      Column(
                        children:
                            mostDispensedMedicine
                                .map(
                                  (med) => Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              med['medicine_name']!,
                                              style: TextStyle(
                                                fontSize: fontSize,
                                                color: textColor,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isDark
                                                      ? Colors.white12
                                                      : Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              med['total_quantity']!,
                                              style: TextStyle(
                                                fontSize: fontSize - 1,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    isDark
                                                        ? Colors.cyanAccent
                                                        : Colors.blueAccent,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Divider(
                                        color: dividerColor,
                                        thickness: 1,
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
