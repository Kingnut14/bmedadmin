import 'package:flutter/material.dart';

class UnreadCountProvider with ChangeNotifier {
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  // This method updates the unread count and notifies listeners
  void updateUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }

  // Optionally, reset unread count to 0 if needed
  void resetUnreadCount() {
    _unreadCount = 0;
    notifyListeners();
  }
}
