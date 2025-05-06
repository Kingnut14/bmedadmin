import 'package:flutter/material.dart';

class ScheduleProvider with ChangeNotifier {
  List<Map<String, String>> _schedules = [];

  List<Map<String, String>> get schedules => _schedules;

  void addSchedule(Map<String, String> schedule) {
    _schedules.add(schedule);
    notifyListeners();
  }

  void editSchedule(int index, Map<String, String> updatedSchedule) {
    _schedules[index] = updatedSchedule;
    notifyListeners();
  }

  void deleteSchedule(int index) {
    _schedules.removeAt(index);
    notifyListeners();
  }
}
