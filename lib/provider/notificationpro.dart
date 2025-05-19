import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'unread_count_provider.dart';

class NotificationItem {
  final int id;
  String title;
  String message;
  DateTime? createdAt;
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
  final Set<int> _pendingDeletes = {}; // Track notifications pending deletion

  List<NotificationItem> get notifications => _notifications;

  Future<void> fetchAdminNotifications(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5566/notification/all/admin'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['retCode'] == '200' && data['data'] != null) {
          final List<NotificationItem> fetched = [];

          for (var item in data['data']) {
            if (_pendingDeletes.contains(item['ID'])) {
              // Skip notifications pending deletion to avoid showing them again
              continue;
            }
            fetched.add(
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

          // Sync _notifications with fetched list:
          // 1. Update existing or add new
          for (var fetchedNotification in fetched) {
            final index = _notifications.indexWhere(
              (n) => n.id == fetchedNotification.id,
            );
            if (index != -1) {
              // Update existing notification
              _notifications[index]
                ..title = fetchedNotification.title
                ..message = fetchedNotification.message
                ..createdAt = fetchedNotification.createdAt
                ..isRead = fetchedNotification.isRead;
            } else {
              // Add new notification
              _notifications.add(fetchedNotification);
            }
          }

          // 2. Remove notifications no longer present in backend
          _notifications.removeWhere(
            (localNotification) =>
                !fetched.any((f) => f.id == localNotification.id),
          );

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

  Future<void> markNotificationAsUnread(int id) async {
    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:5566/notification/$id/unread'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['retCode'] == '200') {
          final index = _notifications.indexWhere((n) => n.id == id);
          if (index != -1) {
            _notifications[index].isRead = false;
            notifyListeners();
          }
        }
      } else {
        debugPrint('Failed to mark notification as unread: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in markNotificationAsUnread: $e');
    }
  }

  void markAllAsRead(BuildContext context) {
    for (var notification in _notifications.where((n) => !n.isRead)) {
      http
          .put(
            Uri.parse(
              'http://127.0.0.1:5566/notification/${notification.id}/read',
            ),
          )
          .then((response) {
            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              if (data['retCode'] == '200') {
                notification.isRead = true;
                updateUnreadCount(context);
                notifyListeners();
              }
            } else {
              debugPrint(
                'Failed to mark notification ${notification.id} as read',
              );
            }
          })
          .catchError((e) {
            debugPrint(
              'Error marking notification ${notification.id} as read: $e',
            );
          });
    }
  }

  void markAllAsUnread(BuildContext context) {
    for (var notification in _notifications.where((n) => n.isRead)) {
      http
          .put(
            Uri.parse(
              'http://127.0.0.1:5566/notification/${notification.id}/unread',
            ),
          )
          .then((response) {
            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              if (data['retCode'] == '200') {
                notification.isRead = false;
                updateUnreadCount(context);
                notifyListeners();
              }
            } else {
              debugPrint(
                'Failed to mark notification ${notification.id} as unread',
              );
            }
          })
          .catchError((e) {
            debugPrint(
              'Error marking notification ${notification.id} as unread: $e',
            );
          });
    }
  }

  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  void clearAll(BuildContext context) {
    _notifications.clear();
    _pendingDeletes.clear();
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

  void restoreNotification(
    int index,
    NotificationItem item,
    BuildContext context,
  ) {
    _notifications.insert(index, item);
    _pendingDeletes.remove(item.id);
    updateUnreadCount(context);
    notifyListeners();
  }

  void deleteNotificationLocally(int id, BuildContext context) {
    _notifications.removeWhere((n) => n.id == id);
    _pendingDeletes.add(id); // Mark as pending deletion
    updateUnreadCount(context);
    notifyListeners();
  }

  void insertNotificationAt(int index, NotificationItem notification) {
    final exists = _notifications.any((n) => n.id == notification.id);
    if (!exists) {
      _notifications.insert(index, notification);
      notifyListeners();
    }
  }

  Future<void> deleteNotificationFromBackend(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:5566/notification/$id/delete'),
        headers: {
          'Content-Type': 'application/json',
          // Add token if needed
          // 'Authorization': 'Bearer YOUR_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        // Successfully deleted from backend
        _pendingDeletes.remove(id);
      } else {
        // Handle error - remove anyway to avoid stuck in pending
        print("Failed to delete notification: ${response.statusCode}");
        _pendingDeletes.remove(id);
      }
    } catch (e) {
      print("Error deleting notification: $e");
      _pendingDeletes.remove(id);
    }
  }
}
