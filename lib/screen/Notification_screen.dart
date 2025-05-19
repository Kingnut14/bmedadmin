import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../provider/notificationpro.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Timer? _timer;
  bool _undoing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      provider.fetchAdminNotifications(context);

      _timer = Timer.periodic(Duration(seconds: 3), (timer) {
        if (!_undoing) {
          provider.fetchAdminNotifications(context);
        } else {
          // Reset undo flag after skipping one fetch
          _undoing = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showNotificationDialog(BuildContext context, notification) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<NotificationProvider>(context, listen: false);

    final String formattedDate =
        (() {
          try {
            final parsedDate = notification.createdAt;
            if (parsedDate != null) {
              final localDate = parsedDate.toLocal();
              return DateFormat('MMMM dd, yyyy – hh:mm a').format(localDate);
            }
            return 'Unknown';
          } catch (_) {
            return 'Unknown';
          }
        })();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                notification.title ?? 'No Title',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.message ?? 'No message',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Date: $formattedDate',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
              actions: [
                if (notification.isRead)
                  TextButton(
                    onPressed: () async {
                      await provider.markNotificationAsUnread(notification.id);
                      if (mounted) {
                        setState(() {
                          notification.isRead = false;
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      'Mark as Unread',
                      style: TextStyle(
                        color: isDarkMode ? Colors.orange[200] : Colors.orange,
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: isDarkMode ? Colors.blue[200] : Colors.blue,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: const Color(0xFFBBDEFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBBDEFB),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: iconColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              final anyUnread = provider.notifications.any((n) => !n.isRead);
              return IconButton(
                tooltip: anyUnread ? 'Mark all read' : 'Mark all unread',
                icon: Icon(
                  anyUnread ? Icons.mark_email_read : Icons.drafts,
                  color: isDarkMode ? Colors.black87 : Colors.black87,
                ),
                onPressed: () {
                  if (anyUnread) {
                    provider.markAllAsRead(context);
                  } else {
                    provider.markAllAsUnread(context);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          final notifications = provider.notifications;

          if (notifications.isEmpty) {
            return const Center(child: Text("No notifications available."));
          }

          final sortedNotifications =
              notifications..sort(
                (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
                  a.createdAt ?? DateTime.now(),
                ),
              );

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: sortedNotifications.length,
            itemBuilder: (context, index) {
              final notification = sortedNotifications[index];
              final isRead = notification.isRead;

              return Dismissible(
                key: Key(notification.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  final removedNotification = notification;

                  provider.deleteNotificationLocally(notification.id, context);

                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                        SnackBar(
                          content: Text(
                            'Notification deleted',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          backgroundColor: Colors.redAccent.shade700,
                          duration: const Duration(seconds: 5),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                          action: SnackBarAction(
                            label: 'Undo',
                            textColor: Colors.yellowAccent,
                            onPressed: () {
                              provider.restoreNotification(
                                index,
                                removedNotification,
                                context,
                              );
                            },
                          ),
                        ),
                      )
                      .closed
                      .then((reason) {
                        if (reason != SnackBarClosedReason.action) {
                          provider.deleteNotificationFromBackend(
                            removedNotification.id,
                          );
                        }
                      });
                },

                child: GestureDetector(
                  onTap: () {
                    if (!isRead) {
                      provider.markNotificationAsRead(notification.id);
                    }
                    _showNotificationDialog(context, notification);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          isRead
                              ? (isDarkMode
                                  ? const Color(0xFF2C2C2E)
                                  : Colors.grey[100])
                              : (isDarkMode
                                  ? const Color(0xFF1A1A2E)
                                  : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isDarkMode
                                  ? Colors.black26
                                  : Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color:
                            isRead
                                ? (isDarkMode
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300)
                                : (isDarkMode
                                    ? Colors.blue.shade400
                                    : Colors.blue.shade100),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isRead
                              ? Icons.notifications_none
                              : Icons.notifications_active,
                          color:
                              isRead
                                  ? (isDarkMode
                                      ? Colors.grey
                                      : Colors.grey.shade600)
                                  : (isDarkMode
                                      ? Colors.blue.shade300
                                      : Colors.blue.shade700),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.title ?? 'No title',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      isRead
                                          ? FontWeight.normal
                                          : FontWeight.w600,
                                  color:
                                      isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notification.message ?? 'No message',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notification.createdAt != null
                                    ? timeago.format(
                                      notification.createdAt!.toLocal(),
                                    )
                                    : 'Unknown time',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isRead
                                          ? (isDarkMode
                                              ? Colors.grey[500]
                                              : Colors.grey[700])
                                          : (isDarkMode
                                              ? Colors.white70
                                              : Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
