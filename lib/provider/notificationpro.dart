import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'unread_count_provider.dart';

class NotificationItem {
  final int id;
  final String title;
  final String message;
  final DateTime? createdAt;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    this.createdAt,
    this.isRead = false,
  });
}

class NotificationProvider with ChangeNotifier {
  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => _notifications;

  Future<void> fetchAdminNotifications(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5566/notification/all/admin'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['retCode'] == '200' && data['data'] != null) {
          _notifications.clear();

          for (var item in data['data']) {
            _notifications.add(
              NotificationItem(
                id: item['ID'],
                title: item['title'] ?? 'No Title',
                message: item['message'] ?? 'No Message',
                createdAt:
                    item['CreatedAt'] != null
                        ? DateTime.tryParse(item['CreatedAt'])
                        : null,
                isRead: item['is_read'] ?? false,
              ),
            );
          }

          updateUnreadCount(context);
          notifyListeners();
        }
      } else {
        debugPrint("Failed to load notifications: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    }
  }

  Future<void> markNotificationAsRead(int id) async {
    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:5566/notification/$id/read'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['retCode'] == '200') {
          final index = _notifications.indexWhere((n) => n.id == id);
          if (index != -1) {
            _notifications[index].isRead = true;
            notifyListeners();
          }
        }
      } else {
        debugPrint('Failed to mark notification as read: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in markNotificationAsRead: $e');
    }
  }

  void markAllAsRead(BuildContext context) {
    for (var n in _notifications) {
      n.isRead = true;
    }
    updateUnreadCount(context);
    notifyListeners();
  }

  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  void clearAll(BuildContext context) {
    _notifications.clear();
    updateUnreadCount(context);
    notifyListeners();
  }

  void toggleRead(int index, BuildContext context) {
    _notifications[index].isRead = !_notifications[index].isRead;
    updateUnreadCount(context);
    notifyListeners();
  }

  void updateUnreadCount(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    Provider.of<UnreadCountProvider>(
      context,
      listen: false,
    ).updateUnreadCount(unreadCount);
  }

  // Retained from your original block
  void removeNotification(int index, BuildContext context) {
    _notifications.removeAt(index);
    updateUnreadCount(context);
    notifyListeners();
  }

  void restoreNotification(
    int index,
    NotificationItem item,
    BuildContext context,
  ) {
    _notifications.insert(index, item);
    updateUnreadCount(context);
    notifyListeners();
  }
}
