import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../provider/unread_count_provider.dart';
// import '../widget/custom_nav_bar.dart';
import 'chat_screen.dart';
import '../widget/custom_app_bar.dart';  // Import the custom app bar

class Chat {
  final String sender;
  final String lastMessage;
  final DateTime timestamp;

  Chat({
    required this.sender,
    required this.lastMessage,
    required this.timestamp,
  });
}

class MessagesScreen extends StatefulWidget {
  final Function(int) onTabSelected;
  const MessagesScreen({super.key, required this.onTabSelected});

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {

  List<Chat> chats = [
    Chat(
      sender: "John",
      lastMessage: "See you later!",
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
    ),
    Chat(
      sender: "Jane",
      lastMessage: "How are you?",
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
    ),
    Chat(
      sender: "Alice",
      lastMessage: "Let's meet tomorrow.",
      timestamp: DateTime.now().subtract(Duration(days: 1)),
    ),
  ];

  // void _onItemTapped(int index) {
  //   if (index != _selectedIndex) {
  //     setState(() {
  //       _selectedIndex = index;
  //     });

  //     switch (index) {
  //       case 0:
  //         Navigator.pushNamed(context, '/home');
  //         break;
  //       case 2:
  //         Navigator.pushNamed(context, '/schedule');
  //         break;
  //     }
  //   }
  // }

  void _openChat(String sender) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(sender: sender)),
    );
  }

  void _deleteChat(int index) {
    if (chats.isNotEmpty && index < chats.length) {
      setState(() {
        chats.removeAt(index);
      });
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    int hour = timestamp.hour;
    String period = hour >= 12 ? "PM" : "AM";
    hour = hour % 12 == 0 ? 12 : hour % 12;
    return "$hour:${timestamp.minute.toString().padLeft(2, '0')} $period";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final unreadCount = Provider.of<UnreadCountProvider>(context).unreadCount;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Medicine List',
        fontSize: 15,
        isDarkMode: theme.brightness == Brightness.dark,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.3, // 50% transparency
                child: Image.asset(
                  'assets/logo.png',
                  width: 500,
                  height: 500,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // LIST OF MESSAGES (ON TOP OF LOGO)
          chats.isEmpty
              ? Center(
            child: Text(
              'No messages yet',
              style: GoogleFonts.poppins(
                  fontSize: 16, color: isDarkMode ? Colors.white : Colors.grey),
            ),
          )
              : ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];

              return Dismissible(
                key: ValueKey(chat.timestamp.millisecondsSinceEpoch),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) => _deleteChat(index),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade500,
                    child: Text(
                      chat.sender[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    chat.sender,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    chat.lastMessage,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _formatTimestamp(chat.timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  onTap: () => _openChat(chat.sender),
                ),
              );
            },
          ),
        ],
      ),
      // bottomNavigationBar: CustomNavBar(
      //   selectedIndex: _selectedIndex,
      //   onItemTapped: _onItemTapped, onScanPressed: () {  },
      // ),
    );
  }
}
