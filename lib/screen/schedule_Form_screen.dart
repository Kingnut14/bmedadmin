import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleFormScreen extends StatefulWidget {
  final Function(int) onTabSelected;
  final Map<String, String>? eventData;

  const ScheduleFormScreen({
    super.key,
    required this.onTabSelected,
    this.eventData,
  });

  @override
  State<ScheduleFormScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleFormScreen> {
  DateTime _selectedDay = DateTime.now();
  String? _startTime;
  String? _endTime;
  late final bool isEditing;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    print('Location: ${_locationController.text}');
    print('Description: ${_descriptionController.text}');

    isEditing = widget.eventData != null;

    if (isEditing) {
      _titleController.text = widget.eventData?['event'] ?? '';
      _locationController.text = widget.eventData?['location'] ?? '';
      _descriptionController.text = widget.eventData?['details'] ?? '';
      _startTime = widget.eventData?['start_time'];
      _endTime = widget.eventData?['end_time'];

      try {
        final rawDate = widget.eventData?['date'];
        if (rawDate != null) {
          if (rawDate.contains('at')) {
            _selectedDay = DateFormat("MMMM d, yyyy 'at' H").parse(rawDate);
          } else {
            _selectedDay = DateFormat('yyyy-MM-dd').parse(rawDate);
          }
        }
      } catch (e) {
        _selectedDay = DateTime.now();
      }
    }
  }

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
      backgroundColor: const Color(0xFFBBDEFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBBDEFB),
        centerTitle: true,
        title: const Text(
          'Create Schedule',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDarkMode
                    ? [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)]
                    : [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionCard(child: _buildCalendar(isDarkMode)),
                const SizedBox(height: 20),
                _sectionCard(child: _buildTimeRangeSelector(isDarkMode)),
                const SizedBox(height: 20),
                _sectionCard(
                  child: _buildTextField(_titleController, 'Event', isDarkMode),
                ),
                const SizedBox(height: 20),
                _sectionCard(
                  child: _buildTextField(
                    _locationController,
                    'Location',
                    isDarkMode,
                  ),
                ),
                const SizedBox(height: 20),
                _sectionCard(
                  child: _buildTextField(
                    _descriptionController,
                    'Description',
                    isDarkMode,
                    maxLines: 4,
                  ),
                ),
                const SizedBox(height: 30),
                _buildSubmitButton(context, () {
                  _submitSchedule(
                    context,
                    _titleController,
                    _locationController,
                    _descriptionController,
                    _selectedDay,
                    _startTime,
                    _endTime,
                  );
                }),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(bool isDarkMode) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      color: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with calendar icon
            Row(
              children: [
                Icon(Icons.date_range, color: Colors.blueAccent),
                const SizedBox(width: 10),
                Text(
                  'Calendar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const Spacer(),
                DropdownButtonHideUnderline(
                  child: DropdownButton<DateTime>(
                    dropdownColor: isDarkMode ? Colors.grey[850] : Colors.white,
                    value: DateTime(_selectedDay.year, _selectedDay.month),
                    items: List.generate(12, (index) {
                      final date = DateTime(DateTime.now().year, index + 1);
                      return DropdownMenuItem(
                        value: date,
                        child: Text(
                          DateFormat.yMMM().format(date),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      );
                    }),
                    onChanged: (selectedDate) {
                      if (selectedDate != null) {
                        setState(() {
                          _selectedDay = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            1,
                          );
                        });
                      }
                    },
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: isDarkMode ? Colors.white70 : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // TableCalendar
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
                todayDecoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: isDarkMode ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                weekendTextStyle: TextStyle(
                  color: isDarkMode ? Colors.red[300] : Colors.red,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[800],
                ),
                weekendStyle: TextStyle(
                  color: isDarkMode ? Colors.red[300] : Colors.redAccent,
                ),
              ),
              headerVisible: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector(bool isDarkMode) {
    final borderColor = Colors.blueAccent;
    final backgroundColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final labelColor = isDarkMode ? Colors.white70 : Colors.black54;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardShadow =
        isDarkMode
            ? Colors.black.withOpacity(0.3)
            : Colors.blueGrey.withOpacity(0.1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule for ${DateFormat.yMMMMd().format(_selectedDay)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _handleStartTimeSelection,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: cardShadow,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: borderColor.withOpacity(0.5)),
                  ),
                  child: _buildTimeDisplay(
                    label: 'Start Time',
                    value: _startTime,
                    labelColor: labelColor,
                    textColor: textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: _handleEndTimeSelection,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: cardShadow,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: borderColor.withOpacity(0.5)),
                  ),
                  child: _buildTimeDisplay(
                    label: 'End Time',
                    value: _endTime,
                    labelColor: labelColor,
                    textColor: textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeDisplay({
    required String label,
    required String? value,
    required Color labelColor,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
        const SizedBox(height: 4),
        Text(
          value ?? '--:--',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  void _handleStartTimeSelection() async {
    final pickedStart = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select Start Time',
      initialEntryMode: TimePickerEntryMode.input,
    );

    if (pickedStart != null && !_isWithinAllowedRange(pickedStart)) {
      _showAlert(
        context,
        'Invalid Time',
        'Start Time must be between 5:00 AM and 6:00 PM.',
      );
      return;
    }

    if (pickedStart != null) {
      setState(() {
        final now = DateTime.now();
        _startTime = DateFormat('hh:mm a').format(
          DateTime(
            now.year,
            now.month,
            now.day,
            pickedStart.hour,
            pickedStart.minute,
          ),
        );
      });
    }
  }

  void _handleEndTimeSelection() async {
    final pickedEnd = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select End Time',
      initialEntryMode: TimePickerEntryMode.input,
    );

    if (pickedEnd != null && !_isWithinAllowedRange(pickedEnd)) {
      _showAlert(
        context,
        'Invalid Time',
        'End Time must be between 5:00 AM and 6:00 PM.',
      );
      return;
    }

    final parsedStart = _parseTimeOfDay(_startTime);
    if (pickedEnd != null &&
        parsedStart != null &&
        !_isEndTimeAfterStartTime(parsedStart, pickedEnd)) {
      _showAlert(
        context,
        'Invalid Time Range',
        'End Time must be later than Start Time.',
      );
      return;
    }

    if (pickedEnd != null) {
      setState(() {
        final now = DateTime.now();
        _endTime = DateFormat('hh:mm a').format(
          DateTime(
            now.year,
            now.month,
            now.day,
            pickedEnd.hour,
            pickedEnd.minute,
          ),
        );
      });
    }
  }

  TimeOfDay? _parseTimeOfDay(String? time) {
    if (time == null) return null;
    try {
      final dateTime = DateFormat('hh:mm a').parse(time);
      return TimeOfDay.fromDateTime(dateTime);
    } catch (_) {
      return null;
    }
  }

  bool _isWithinAllowedRange(TimeOfDay time) {
    const minHour = 5;
    const maxHour = 18;

    if (time.hour < minHour || time.hour > maxHour) return false;
    return true;
  }

  bool _isEndTimeAfterStartTime(TimeOfDay start, TimeOfDay end) {
    final startInMinutes = start.hour * 60 + start.minute;
    final endInMinutes = end.hour * 60 + end.minute;
    return endInMinutes > startInMinutes;
  }

  Future<void> _submitSchedule(
    BuildContext context,
    TextEditingController titleController,
    TextEditingController locationController,
    TextEditingController descriptionController,
    DateTime selectedDay,
    String? startTime,
    String? endTime,
  ) async {
    if (titleController.text.isEmpty ||
        locationController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      _showAlert(context, 'Error', 'Please fill in all fields.');
      return;
    }

    if (startTime == null || endTime == null) {
      _showAlert(context, 'Error', 'Please select a valid time range.');
      return;
    }

    final url = Uri.parse('http://127.0.0.1:5566/schedule/insert');

    final Map<String, dynamic> scheduleData = {
      'event': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'date': selectedDay.toUtc().toIso8601String(),
      'location': locationController.text.trim(),
      'start_time': startTime,
      'end_time': endTime,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(scheduleData),
      );

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['retCode'] == '201') {
          _showAlertAndNavigateBack(context);
        } else {
          _showAlert(
            context,
            'Error',
            responseData['message'] ?? 'Failed to add schedule.',
          );
        }
      } else {
        _showAlert(
          context,
          'Server Error',
          'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      _showAlert(context, 'Error', 'Error: $e');
    }
  }

  void _showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
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

  void _showAlertAndNavigateBack(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Schedule has been added successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // closes the dialog
                  Navigator.pop(
                    context,
                    true,
                  ); // navigates back to previous screen
                  widget.onTabSelected(1); // triggers tab change if needed
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}

Widget _buildTextField(
  TextEditingController controller,
  String label,
  bool isDarkMode, {
  int maxLines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF2A2A40) : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    ),
  );
}

Widget _buildSubmitButton(BuildContext context, VoidCallback onPressed) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? Colors.blueAccent : Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Submit',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
  );
}

Widget _sectionCard({required Widget child}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.85),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    padding: const EdgeInsets.all(16),
    child: child,
  );
}
