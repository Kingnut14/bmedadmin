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
                                isDarkMode
                                    ? Color(0xFF2C3E50)
                                    : Color(0xFFE3F2FD),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          20,
        ), // Rounded corners for modern look
      ),
      elevation: 12,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? Color(0xFF2C3E50)
                  : Colors.white, // Dark mode background color
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              eventData["event"]!,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color:
                    isDarkMode
                        ? Colors.white
                        : Colors.blueAccent, // Adjust text color for dark mode
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Date: ${eventData["date"]}',
              style: TextStyle(
                fontSize: 18,
                color:
                    isDarkMode
                        ? Colors.grey[300]
                        : Colors.grey[700], // Adjust color for dark mode
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start Time: ${eventData["start_time"]}', // Show start time
              style: TextStyle(
                fontSize: 16,
                color:
                    isDarkMode
                        ? Colors.white70
                        : Colors.black87, // Adjust color for dark mode
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'End Time: ${eventData["end_time"]}', // Show end time
              style: TextStyle(
                fontSize: 16,
                color:
                    isDarkMode
                        ? Colors.white70
                        : Colors.black87, // Adjust color for dark mode
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Details: ${eventData["details"]}',
              style: TextStyle(
                fontSize: 16,
                color:
                    isDarkMode
                        ? Colors.white70
                        : Colors.black87, // Adjust color for dark mode
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the modal
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      30,
                    ), // More rounded corners for a sleek look
                  ),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shadowColor: Colors.blueAccent.withOpacity(
                    0.3,
                  ), // Subtle shadow effect
                  elevation: 10, // Smooth elevation effect
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color:
                        Colors.white, // White text color for better visibility
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
