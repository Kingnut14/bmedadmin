import 'package:bmedv2/provider/notificationpro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/unread_count_provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
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
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Fetch notifications on app bar init (or move this to home screen init)
      await context.read<NotificationProvider>().fetchAdminNotifications(
        context,
      );

      // Then update unread count after fetch
      _updateUnreadCount();
    });
  }

  void _updateUnreadCount() {
    final notificationProvider = context.read<NotificationProvider>();
    final unreadCount = notificationProvider.getUnreadCount();
    context.read<UnreadCountProvider>().updateUnreadCount(unreadCount);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = const Color(
      0xFFBBDEFB,
    ); // from first block, keep your requested color
    final iconColor = widget.isDarkMode ? Colors.white : Colors.black87;

    final currentRoute = ModalRoute.of(context)?.settings.name;
    final onNotificationScreen = currentRoute == '/Notification_screen';

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Container(
        height: widget.preferredSize.height,
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left icon (back arrow if on notification screen, else menu drawer)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  icon: Icon(
                    onNotificationScreen
                        ? Icons.arrow_back_ios_new_rounded
                        : Icons.menu,
                    size: 22,
                    color: iconColor,
                  ),
                  tooltip: onNotificationScreen ? 'Back' : 'Settings',
                  onPressed: () {
                    if (onNotificationScreen) {
                      Navigator.pop(context);
                    } else {
                      Scaffold.of(context).openDrawer();
                    }
                  },
                ),
              ),

              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/baramedlogo_v4.png',
                    height: 600,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Right notification icon with unread badge if NOT on notification screen
              if (!onNotificationScreen)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications_none,
                          size: 22,
                          color: iconColor,
                        ),
                        tooltip: 'Notifications',
                        onPressed:
                            () => Navigator.pushNamed(
                              context,
                              '/Notification_screen',
                            ),
                      ),
                      Positioned(
                        right: 4,
                        top: 6,
                        child: Consumer<UnreadCountProvider>(
                          builder: (context, unreadProvider, _) {
                            final unreadCount = unreadProvider.unreadCount;
                            return unreadCount > 0
                                ? Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
