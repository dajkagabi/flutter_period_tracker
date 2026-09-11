import 'package:flutter/material.dart';
import 'package:flutter_period_tracker/features/cycle%20tracking/presentation/screens/calendar_screen.dart'
    show CalendarScreen;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        //Élesszöveg vagy nem
        typography: Typography.material2021(),
      ),
      home: const CalendarScreen(),
    );
  }
}
