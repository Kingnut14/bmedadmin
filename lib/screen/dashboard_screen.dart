import 'package:bmedv2/provider/notificationpro.dart';
import 'package:bmedv2/scanner/accepted_screen%20updated.dart';
import 'package:bmedv2/screen/menu_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:table_calendar/table_calendar.dart';
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
  String? selectedMonth;
  String? selectedYear;
  bool _showFilters = false;
  DateTime _focusedDay = DateTime.now();
  bool _showAllEvents = false;
  int _expandedEventIndex = -1;
  bool _showAllMedicines = false;

  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  List<String> years = [
    '2021',
    '2022',
    '2023',
    '2024',
    '2025',
    '2026', // Add more years if necessary
  ];

  final Map<String, String> monthNameToNumber = {
    'January': '01',
    'February': '02',
    'March': '03',
    'April': '04',
    'May': '05',
    'June': '06',
    'July': '07',
    'August': '08',
    'September': '09',
    'October': '10',
    'November': '11',
    'December': '12',
  };

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<NotificationProvider>().fetchAdminNotifications(
        context,
      );
      final unreadCount = context.read<NotificationProvider>().getUnreadCount();
      context.read<UnreadCountProvider>().updateUnreadCount(unreadCount);
    });
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
    String url = 'http://127.0.0.1:5566/dashboard';

    if (selectedMonth != null && selectedYear != null) {
      String monthNum = monthNameToNumber[selectedMonth!] ?? '01';
      String formattedMonthYear = '${selectedYear!.padLeft(4, '0')}-$monthNum';
      url += '?monthYear=$formattedMonthYear';
    }

    // print("Fetching from: $url");

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final data = decoded['data'] ?? {};

      List<dynamic> availableMedicines = data['available_medicines'] ?? [];
      List<dynamic> mostDispensedMedicines =
          data['most_dispensed_medicines'] ?? [];
      List<dynamic> schedules = data['schedules'] ?? [];

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
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _fetchMedicinesData();
      await _fetchNotificationsAndUpdateUnreadCount(); // add this line
    });
  }

    Future<void> _fetchNotificationsAndUpdateUnreadCount() async {
    final notificationProvider = context.read<NotificationProvider>();
    await notificationProvider.fetchAdminNotifications(context);
    final unreadCount = notificationProvider.getUnreadCount();
    context.read<UnreadCountProvider>().updateUnreadCount(unreadCount);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSize = Provider.of<FontSizeProvider>(context).fontSize;
    final unreadCount = Provider.of<UnreadCountProvider>(context).unreadCount;

    double screenWidth = MediaQuery.of(context).size.width;
    double scaledFontSize = fontSize + (screenWidth / 375);

    String appBarTitle = "BaraMed";
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
      drawer: const MenuScreen(),
      backgroundColor:
          themeProvider.isDarkMode ? Colors.black : const Color(0xFFBBDEFB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildMostDispensedMedicines(
                themeProvider,
                scaledFontSize,
                screenWidth,
              ),
              _buildUpcomingSchedule(themeProvider, scaledFontSize),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildTotalMedicines(
                    themeProvider,
                    scaledFontSize,
                    screenWidth,
                  ),

              _buildTwoColumnLayout(themeProvider, scaledFontSize, screenWidth),
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

  // Most Dispensed Medicines Section
  Widget _buildMostDispensedMedicines(
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
      Colors.indigo,
      Colors.teal,
      Colors.brown,
      Colors.grey,
      Colors.amber,
      Colors.lime,
      Colors.pink,
      Colors.deepPurple,
      Colors.deepOrange,
    ];

    if (mostDispensedMedicine.isNotEmpty) {
      mostDispensedMedicine.sort(
        (a, b) => int.parse(
          b['total_quantity']!,
        ).compareTo(int.parse(a['total_quantity']!)),
      );

      List<Map<String, String>> topMedicines =
          mostDispensedMedicine.take(10).toList();
      List<Map<String, String>> otherMedicines =
          mostDispensedMedicine.skip(10).toList();

      totalQuantity = mostDispensedMedicine.fold(
        0,
        (sum, med) => sum + int.parse(med['total_quantity']!),
      );

      for (int i = 0; i < topMedicines.length; i++) {
        int quantity = int.parse(topMedicines[i]['total_quantity']!);
        double percentage = (quantity / totalQuantity) * 100;

        sections.add(
          PieChartSectionData(
            value: quantity.toDouble(),
            title: "${percentage.toStringAsFixed(1)}%",
            radius: mostDispensedMedicine.length > 10 ? 50 : 60,
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
          (sum, med) => sum + int.parse(med['total_quantity']!),
        );
        double percentage = (otherQuantity / totalQuantity) * 100;

        sections.add(
          PieChartSectionData(
            value: otherQuantity.toDouble(),
            title: "${percentage.toStringAsFixed(1)}%",
            radius: mostDispensedMedicine.length > 10 ? 50 : 60,
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
      sections.add(
        PieChartSectionData(
          value: 1,
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            themeProvider.isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Dispensed Medicine",
                style: TextStyle(
                  fontSize: fontSize + 4,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              IconButton(
                icon: Icon(
                  _showFilters
                      ? Icons.filter_alt_off
                      : Icons.filter_alt_outlined,
                  color:
                      themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.black87,
                ),
                tooltip: "Filter by Month/Year",
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
              ),
            ],
          ),

          if (_showFilters)
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedMonth,
                      decoration: InputDecoration(
                        labelText: 'Month',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                      ),
                      dropdownColor:
                          themeProvider.isDarkMode
                              ? const Color(0xFF2C2C2C)
                              : Colors.white,
                      items:
                          months.map((String month) {
                            return DropdownMenuItem<String>(
                              value: month,
                              child: Text(month),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedMonth = newValue;
                          });
                          _fetchMedicinesData();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedYear,
                      decoration: InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                      ),
                      dropdownColor:
                          themeProvider.isDarkMode
                              ? const Color(0xFF2C2C2C)
                              : Colors.white,
                      items:
                          years.map((String year) {
                            return DropdownMenuItem<String>(
                              value: year,
                              child: Text(year),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedYear = newValue;
                          });
                          _fetchMedicinesData();
                        }
                      },
                    ),
                  ),

                  // Clear button
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear filter',
                    onPressed: () {
                      setState(() {
                        selectedMonth = null;
                        selectedYear = null;
                      });
                      _fetchMedicinesData();
                    },
                  ),
                ],
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
                  mostDispensedMedicine.isEmpty ? "No data" : "$totalQuantity ",
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
          mostDispensedMedicine.isEmpty
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
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mostDispensedMedicine.length,
                itemBuilder: (context, index) {
                  final medicine = mostDispensedMedicine[index];
                  Color color =
                      index < 10
                          ? customColors[index % customColors.length]
                          : Colors.grey;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(medicine['medicine_name']!),
                              content: Text(
                                "Quantity: ${medicine['total_quantity']}",
                              ),
                              actions: [
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
                                medicine['medicine_name']!,
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
                            "${medicine['total_quantity']} pcs",
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

  Widget _buildTotalMedicines(
    ThemeProvider themeProvider,
    double fontSize,
    double screenWidth,
  ) {
    final bool isDark = themeProvider.isDarkMode;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color bgColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final Color dividerColor = isDark ? Colors.white12 : Colors.grey.shade200;

    // State to track show all toggle, you need to add this to your StatefulWidget class:
    // bool _showAllMedicines = false;

    // Medicines to show based on toggle
    final displayedMedicines =
        _showAllMedicines
            ? medicines
            : medicines.length > 5
            ? medicines.take(5).toList()
            : medicines;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    FeatherIcons.box,
                    color: isDark ? Colors.cyanAccent : Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Available Medicines",
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
              Column(
                children:
                    displayedMedicines.map((med) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  med['name']!,
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
                                          : Colors.blue.shade50.withOpacity(
                                            0.6,
                                          ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  med['quantity']!,
                                  style: TextStyle(
                                    fontSize: fontSize - 1,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark
                                            ? Colors.cyanAccent
                                            : Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Divider(color: dividerColor, thickness: 1),
                          const SizedBox(height: 8),
                        ],
                      );
                    }).toList(),
              ),

              // Show All / Show Less button
              if (medicines.length > 5)
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showAllMedicines = !_showAllMedicines;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      _showAllMedicines
                          ? 'Show Less'
                          : 'Show All (${medicines.length})',
                      style: TextStyle(
                        color: isDark ? Colors.cyanAccent : Colors.blue,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // UPCOMING SCHEDULE SECTION
  Widget _buildUpcomingSchedule(ThemeProvider themeProvider, double fontSize) {
    final isDark = themeProvider.isDarkMode;
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF7F9FC);
    final textColor = isDark ? Colors.white : Colors.black87;
    final fadedTextColor = isDark ? Colors.grey[400] : Colors.grey[800];
    final accentColor = const Color(0xFF2196F3);

    final allSchedules = backendSchedules;

    final schedules =
        allSchedules.where((schedule) {
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

    bool isSameDay(DateTime d1, DateTime d2) =>
        d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;

    String formatTime(String timeString) {
      try {
        final parsedTime = DateFormat.jm().parse(timeString);
        return DateFormat.jm().format(parsedTime);
      } catch (e) {
        return timeString;
      }
    }

    List<Map<String, String>> getEventsForDay(DateTime day) {
      return schedules
          .where((schedule) => isSameDay(DateTime.parse(schedule["date"]), day))
          .map(
            (schedule) => {
              "event": schedule["event"].toString(),
              "description": schedule["description"].toString(),
              "date": schedule["date"].toString(),
              "start_time": schedule["start_time"].toString(),
              "end_time": schedule["end_time"].toString(),
            },
          )
          .toList();
    }

    final events = getEventsForDay(_selectedDay);
    final displayedEvents = _showAllEvents ? events : events.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2021, 1, 1),
                  lastDay: DateTime.utc(2026, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarFormat: CalendarFormat.week,
                  availableCalendarFormats: const {CalendarFormat.week: 'Week'},
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: const TextStyle(color: Colors.red),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: fontSize + 2,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    leftChevronIcon: const Icon(
                      Icons.chevron_left,
                      color: Colors.black,
                    ),
                    rightChevronIcon: const Icon(
                      Icons.chevron_right,
                      color: Colors.black,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: const TextStyle(color: Colors.black),
                    weekendStyle: const TextStyle(color: Colors.redAccent),
                  ),
                  eventLoader: getEventsForDay,
                ),
                const SizedBox(height: 16),
                if (events.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No events for this day.',
                        style: TextStyle(
                          fontSize: fontSize,
                          color: fadedTextColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      ...displayedEvents.asMap().entries.map((entry) {
                        final index = entry.key;
                        final event = entry.value;
                        final isExpanded = _expandedEventIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _expandedEventIndex = isExpanded ? -1 : index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? const Color(0xFF2D2D2D)
                                      : const Color(0xFFBBDEFB),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color:
                                            isDark
                                                ? const Color(0xFF1E1E1E)
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.event,
                                        color:
                                            isDark
                                                ? Colors.white
                                                : const Color(0xFF0D47A1),
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 4,
                                            ),
                                            margin: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isDark
                                                      ? const Color(0xFF1E1E1E)
                                                      : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              DateFormat.yMMMMd().format(
                                                _selectedDay,
                                              ),
                                              style: TextStyle(
                                                fontSize: fontSize,
                                                fontWeight: FontWeight.w600,
                                                color: textColor,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            event['event']!,
                                            style: TextStyle(
                                              fontSize: fontSize + 2,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      isExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: textColor,
                                    ),
                                  ],
                                ),
                                if (isExpanded) ...[
                                  Divider(
                                    color: Colors.black12,
                                    thickness: 1,
                                    height: 20,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    event['description']!,
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      color: fadedTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: fadedTextColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${formatTime(event['start_time']!)} - ${formatTime(event['end_time']!)}',
                                        style: TextStyle(
                                          fontSize: fontSize - 2,
                                          color: fadedTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      if (events.length > 3)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _showAllEvents = !_showAllEvents;
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              _showAllEvents
                                  ? 'Show Less'
                                  : 'Show All (${events.length})',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: fontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Third button: Dispensed
              Expanded(
                child: _buildQuickActionButton(
                  themeProvider,
                  fontSize,
                  'Medicine List',
                  Icons.medical_services,
                  MedicineListScreen(),
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
          color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 1),
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
}
