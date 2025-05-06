import 'package:bmedv2/provider/unread_count_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationItem {
  final String title;
  final String message;
  bool isRead;

  NotificationItem({required this.title, required this.message, this.isRead = false});
}

class NotificationProvider with ChangeNotifier {
  final List<NotificationItem> _notifications = [
    NotificationItem(title: "Order Confirmed", message: "Your order #1234 has been confirmed."),
    NotificationItem(title: "Delivery", message: "Your package is on the way."),
    NotificationItem(title: "Reminder", message: "Don’t forget to take your medicine."),
    NotificationItem(title: "New Feature", message: "Check out our new feature in the app!"),
    NotificationItem(title: "Feedback", message: "We value your feedback. Please rate us."),
    NotificationItem(title: "Update Available", message: "A new version of the app is available."),
    NotificationItem(title: "Security Alert", message: "Unusual login attempt detected."),
    NotificationItem(title: "Appointment Reminder", message: "Your appointment is tomorrow at 10 AM."),
  ];

  List<NotificationItem> get notifications => _notifications;

  void markAllAsRead(BuildContext context) {
    for (var n in _notifications) {
      n.isRead = true;
    }
    updateUnreadCount(context); // Update unread count after marking all as read
    notifyListeners();
  }

    int getUnreadCount() {
  return _notifications.where((n) => !n.isRead).length;
}

  void clearAll(BuildContext context) {
    _notifications.clear();
    updateUnreadCount(context); // Update unread count after clearing all
    notifyListeners();
  }

  void toggleRead(int index, BuildContext context) {
    _notifications[index].isRead = !_notifications[index].isRead;
    updateUnreadCount(context); // Update unread count after toggling a notification
    notifyListeners();
  }

  // This method updates the unread count and notifies the UnreadCountProvider
void updateUnreadCount(BuildContext context) {
  final unreadCount = _notifications.where((n) => !n.isRead).length;
  Provider.of<UnreadCountProvider>(context, listen: false).updateUnreadCount(unreadCount);
}


}
