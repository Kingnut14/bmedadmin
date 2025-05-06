// import 'package:bmedv2/widget/custom_nav_bar.dart';
import 'package:bmedv2/provider/notificationpro.dart';
import 'package:bmedv2/screen/User_screen.dart';
import 'package:bmedv2/screen/message_screen.dart';
import 'package:bmedv2/screen/ocr_medicine_scanner.dart';
import 'package:bmedv2/screen/schedule_screen.dart';
import 'package:bmedv2/widget/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/theme_provider.dart';
import 'provider/font_size_provider.dart';
import 'provider/unread_count_provider.dart';  // Add the import
import 'screen/dashboard_screen.dart';
import 'scanner/qr_scanner_screen.dart';
import 'scanner/accepted_screen.dart';
import 'screen/setting_screen.dart';
import 'screen/notification_screen.dart'; // make sure file name matches


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        ChangeNotifierProvider(create: (_) => UnreadCountProvider()), // Add the provider here
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, FontSizeProvider>(
      builder: (context, themeProvider, fontSizeProvider, _) {
        final double fontSize = fontSizeProvider.fontSize;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BaraMed App',
          home: MainScreen(),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.blue.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontSize: fontSize),
              bodyMedium: TextStyle(fontSize: fontSize),
              bodySmall: TextStyle(fontSize: fontSize),
              titleLarge: TextStyle(fontSize: fontSize * 1.5, fontWeight: FontWeight.bold),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.black,
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey.shade800,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontSize: fontSize),
              bodyMedium: TextStyle(fontSize: fontSize),
              bodySmall: TextStyle(fontSize: fontSize),
              titleLarge: TextStyle(fontSize: fontSize * 1.5, fontWeight: FontWeight.bold),
            ),
          ),
          initialRoute: '/',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(builder: (_) => DashboardScreen(onTabSelected: (int index) {  },));
              case '/message_screen':
                return MaterialPageRoute(builder: (_) => MessagesScreen(onTabSelected: (int index) {  },));
              case '/ocr_medicine_scanner':
                return MaterialPageRoute(builder: (_) => OcrMedicineScanner(onTabSelected: (int index) {  },));
              case '/schedule_scanner':
                return MaterialPageRoute(builder: (_) => ScheduleScreen(onTabSelected: (int index) {  },));
              case '/User_screen':
                return MaterialPageRoute(builder: (_) => UserManagementScreen(onTabSelected: (int index) {  },));
              case '/settings':
                return MaterialPageRoute(builder: (_) => const SettingsScreen());
              case '/Notification_screen':
                return MaterialPageRoute(builder: (_) => const NotificationScreen());
              case '/qr':
                return MaterialPageRoute(builder: (_) => const ModernQRScanner());
              case '/accepted':
                final args = settings.arguments;
                if (args is Map<String, dynamic> && args['parsedRequests'] is List<Map<String, String>>) {
                  final parsedRequests = args['parsedRequests'] as List<Map<String, String>>;
                  return MaterialPageRoute(
                    builder: (_) => AcceptedScreen(parsedRequests: parsedRequests),
                  );
                } else {
                  return _errorRoute("Missing or invalid arguments for AcceptedScreen");
                }
              default:
                return _errorRoute("Page not found: ${settings.name}");
            }
          },
        );
      },
    );
  }

  MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
