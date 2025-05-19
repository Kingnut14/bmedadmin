import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/notificationpro.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Timer? _timer;

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
        provider.fetchAdminNotifications(context);
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
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            notification.title,
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
                notification.message,
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
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(
                  color: isDarkMode ? Colors.blue[200] : Colors.blue,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
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
        backgroundColor: isDarkMode ? Colors.black87 : const Color(0xFFBBDEFB),
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          tooltip: 'Back',
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
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          final notifications = provider.notifications;

          if (notifications.isEmpty) {
            return const Center(child: Text("No notifications available."));
          }

          // Sort by newest first
          final sortedNotifications = [...notifications]..sort(
            (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
              a.createdAt ?? DateTime.now(),
            ),
          );

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: sortedNotifications.length,
            itemBuilder: (context, index) {
              final notification = sortedNotifications[index];
              final formattedDate = DateFormat.yMMMd().add_jm().format(
                notification.createdAt ?? DateTime.now(),
              );

              final isRead = notification.isRead;

              return GestureDetector(
                onTap: () {
                  provider.markNotificationAsRead(notification.id);
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
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isRead
                                        ? FontWeight.normal
                                        : FontWeight.w600,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notification.message,
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
                              formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isDarkMode ? Colors.grey : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
