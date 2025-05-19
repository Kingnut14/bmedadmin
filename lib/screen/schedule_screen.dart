import 'dart:convert';
import 'package:bmedv2/screen/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bmedv2/widget/custom_app_bar.dart';
import 'package:bmedv2/screen/schedule_Form_screen.dart'; // Import the ScheduleFormScreen
import 'package:intl/intl.dart'; // Import intl package for date formatting

class ScheduleScreen extends StatefulWidget {
  final void Function(int)? onTabSelected;

  ScheduleScreen({this.onTabSelected});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Map<String, String>> events = [];
  bool isLoading = true; // Ensure loading state starts as true
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchSchedules();
  }

  Future<void> fetchSchedules() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5566/schedule'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['retCode'] == '200') {
          setState(() {
            events = List<Map<String, String>>.from(
              data['data'].map((event) {
                return {
                  "event":
                      event["event"]?.toString() ?? "", // Ensure it's a string
                  "details":
                      event["description"]?.toString() ??
                      "", // Ensure it's a string
                  "date": formatDate(event["date"] ?? ""), // Format the date
                  "start_time":
                      event["start_time"]?.toString() ??
                      "", // Ensure it's a string
                  "end_time":
                      event["end_time"]?.toString() ??
                      "", // Ensure it's a string
                  "location":
                      event["location"]?.toString() ??
                      "", // Ensure it's a string
                };
              }),
            );
            isLoading = false;
            hasError = false;
          });
        } else {
          setState(() {
            isLoading = false;
            hasError = true;
          });
        }
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      print('Error: $e'); // Debugging: print error message
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  // Function to format date
  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(
        dateString,
      ); // Convert the string to DateTime
      return DateFormat(
        'MMMM d, yyyy',
      ).format(date); // Format to "February 2, 2025"
    } catch (e) {
      return dateString; // Return original string if invalid date
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? const Color(0xFF121212)
              : const Color(0xFFBBDEFB), // Example colors
      appBar: CustomAppBar(
        title: "Barangay Announcements",
        isDarkMode: isDarkMode,
        fontSize: 18,
      ),
      drawer: const MenuScreen(),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : hasError
              ? Center(child: Text('Failed to load events'))
              : events.isEmpty
              ? Center(child: Text('No events available'))
              : ListView(
                children:
                    events.map((eventData) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            // Show the event details in a modal dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return EventDetailModal(eventData: eventData);
                              },
                            );
                          },
                          child: Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            color:
                                isDarkMode ? Color(0xFF2C3E50) : Colors.white,
                            shadowColor: Colors.blueAccent.withOpacity(0.5),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal: 16.0,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_alarm,
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.blueAccent,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          eventData["event"]!,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                isDarkMode
                                                    ? Colors.white
                                                    : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          eventData["date"]!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                isDarkMode
                                                    ? Colors.grey[400]
                                                    : Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScheduleFormScreen(onTabSelected: (int) {}),
            ),
          );

          // Refresh the schedules if new data was added
          if (result == true) {
            fetchSchedules();
          }
        },

        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}

class EventDetailModal extends StatelessWidget {
  final Map<String, String> eventData;

  EventDetailModal({required this.eventData});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final surfaceColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final labelColor = isDark ? Colors.grey[400] : Colors.grey[700];

    return Dialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              eventData["event"] ?? 'Untitled Event',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),

            _eventDetailTile(
              icon: Icons.calendar_today,
              title: 'Date',
              value: eventData["date"],
              color: labelColor!,
              textColor: textColor,
            ),
            _eventDetailTile(
              icon: Icons.schedule,
              title: 'Start Time',
              value: eventData["start_time"],
              color: labelColor,
              textColor: textColor,
            ),
            _eventDetailTile(
              icon: Icons.schedule_outlined,
              title: 'End Time',
              value: eventData["end_time"],
              color: labelColor,
              textColor: textColor,
            ),
            _eventDetailTile(
              icon: Icons.description_outlined,
              title: 'Details',
              value: eventData["details"],
              color: labelColor,
              textColor: textColor,
            ),
            _eventDetailTile(
              icon: Icons.place_outlined,
              title: 'Location',
              value: eventData["location"],
              color: labelColor,
              textColor: textColor,
            ),

            const Divider(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ScheduleFormScreen(
                                eventData: eventData,
                                onTabSelected: (_) {},
                              ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.blueAccent : Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark ? Colors.blueAccent : Colors.blue,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _eventDetailTile({
    required IconData icon,
    required String title,
    required String? value,
    required Color color,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, color: color)),
                const SizedBox(height: 2),
                Text(
                  value ?? '-',
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
