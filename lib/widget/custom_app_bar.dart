import 'package:bmedv2/provider/notificationpro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/unread_count_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isDarkMode;
  final double fontSize;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.isDarkMode,
    this.fontSize = 18.0,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode ? Colors.black87 : Colors.white;
    final iconColor = isDarkMode ? Colors.white70 : Colors.black87;

      WidgetsBinding.instance.addPostFrameCallback((_) {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final unreadCount = notificationProvider.getUnreadCount();
    Provider.of<UnreadCountProvider>(context, listen: false).updateUnreadCount(unreadCount);
  });
  
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final onNotificationScreen = currentRoute == '/Notification_screen';

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Container(
        height: preferredSize.height,
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              // Always show back button if on notification screen
            Row(
              children: [
                if (onNotificationScreen)
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: iconColor),
                    onPressed: () => Navigator.pop(context),
                  )
                else
                  IconButton(
                    icon: Icon(Icons.settings_outlined, size: 20, color: iconColor),
                    tooltip: 'Settings',
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                  ),
              ],
            ),


              // Title
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ),
              ),

              // Right-side icons
              Row(
                children: [
                  if (!onNotificationScreen)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications_none, size: 20, color: iconColor),
                          tooltip: 'Notifications',
                          onPressed: () => Navigator.pushNamed(context, '/Notification_screen'),
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Consumer<UnreadCountProvider>(
                            builder: (context, unreadProvider, _) {
                              final unreadCount = unreadProvider.unreadCount;
                              return unreadCount > 0
                                  ? Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$unreadCount',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink();
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
