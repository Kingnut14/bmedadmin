import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:bmedv2/widget/custom_nav_bar.dart';
import 'package:table_calendar/table_calendar.dart';

import '../widget/custom_app_bar.dart';

class ScheduleScreen extends StatefulWidget {
  final Function(int) onTabSelected;
  const ScheduleScreen({super.key, required this.onTabSelected});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDay = DateTime.now();
  String? _startTime;
  String? _endTime;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Schedule',
        fontSize: 15,
        isDarkMode: isDarkMode,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalendar(isDarkMode),
                    const SizedBox(height: 20),
                    _buildTimeRangeSelector(isDarkMode),
                    const SizedBox(height: 20),
                    _buildTextField(_titleController, 'Event', isDarkMode),
                    const SizedBox(height: 15),
                    _buildTextField(_locationController, 'Location', isDarkMode),
                    const SizedBox(height: 15),
                    _buildTextField(
                      _descriptionController,
                      'Description',
                      isDarkMode,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),
                    _buildSubmitButton(
                      context,
                          () {
                        _submitSchedule(
                          context,
                          _titleController,
                          _locationController,
                          _descriptionController,
                          _selectedDay,
                          _startTime,
                          _endTime,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: CustomNavBar(
      //   selectedIndex: 3, // Assuming 3 is the index of the current screen
      //   onItemTapped: (index) {
      //     // Handle navigation if necessary
      //   },
      //   onScanPressed: () {},
      // ),
    );
  }

  Widget _buildCalendar(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Month & Year:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            DropdownButton<DateTime>(
              value: DateTime(_selectedDay.year, _selectedDay.month),
              items: List.generate(12, (index) {
                final date = DateTime(DateTime.now().year, index + 1);
                return DropdownMenuItem(
                  value: date,
                  child: Text(DateFormat.yMMM().format(date)),
                );
              }),
              onChanged: (selectedDate) {
                if (selectedDate != null) {
                  setState(() {
                    _selectedDay = DateTime(selectedDate.year, selectedDate.month, 1);
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        TableCalendar(
          focusedDay: _selectedDay,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
            });
          },
          calendarStyle: CalendarStyle(
            todayTextStyle: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            selectedTextStyle: TextStyle(
              color: isDarkMode ? Colors.black : Colors.white,
            ),
            selectedDecoration: BoxDecoration(
              color: isDarkMode ? Colors.blueAccent : Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRangeSelector(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Range for ${DateFormat.yMd().format(_selectedDay)}:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.blue : Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? pickedStart = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              helpText: ' Start Time',
            );

            if (pickedStart != null) {
              final TimeOfDay? pickedEnd = await showTimePicker(
                context: context,
                initialTime: pickedStart,
                helpText: 'End Time',
              );

              if (pickedEnd != null) {
                if (_isEndTimeAfterStartTime(pickedStart, pickedEnd)) {
                  setState(() {
                    _startTime = pickedStart.format(context);
                    _endTime = pickedEnd.format(context);
                  });
                } else {
                  _showAlert(context, 'End Time must be later than Start Time.');
                }
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade500),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Time',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _startTime ?? '--:--',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward, size: 24, color: Colors.blueAccent),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End Time',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _endTime ?? '--:--',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _isEndTimeAfterStartTime(TimeOfDay start, TimeOfDay end) {
    final startInMinutes = start.hour * 60 + start.minute;
    final endInMinutes = end.hour * 60 + end.minute;
    return endInMinutes > startInMinutes;
  }

  Future<void> _submitSchedule(BuildContext context,
      TextEditingController titleController,
      TextEditingController locationController,
      TextEditingController descriptionController,
      DateTime selectedDay,
      String? startTime,
      String? endTime) async {
    if (titleController.text.isEmpty || locationController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      _showAlert(context, 'Please fill in all fields.');
      return;
    }

    if (startTime == null || endTime == null) {
      _showAlert(context, 'Please select a valid time range.');
      return;
    }

    // Submit logic
    Navigator.pop(context);
  }

  void _showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Widget _buildTextField(TextEditingController controller,
      String label,
      bool isDarkMode, {
        int maxLines = 1,
      }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        fillColor: isDarkMode ? Colors.grey[850] : Colors.white,
        filled: true,
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildSubmitButton(BuildContext context, VoidCallback onPressed) {
    final isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? Colors.blueAccent : Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: const Text(
          'Submit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
