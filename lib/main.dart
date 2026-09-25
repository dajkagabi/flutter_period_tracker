import 'package:flutter/material.dart';
import 'package:flutter_period_tracker/core/services/notification_service.dart';
import 'package:flutter_period_tracker/features/cycle%20tracking/presentation/screens/calendar_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Értesítési szolgáltatás indítása
  //(az init() metódus tartalmazza az engedélykérést is)
  await NotificationService().init();

  runApp(const PeriodTrackerApp());
}

class PeriodTrackerApp extends StatelessWidget {
  const PeriodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cikluskövető',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home: const CalendarScreen(),
    );
  }
}
