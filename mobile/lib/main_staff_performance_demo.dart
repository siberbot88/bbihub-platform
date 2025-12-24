import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'feature/admin/screens/staff_performance_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const StaffPerformanceDemoApp());
}

class StaffPerformanceDemoApp extends StatelessWidget {
  const StaffPerformanceDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Staff Performance Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFFE53935),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935),
          primary: const Color(0xFFE53935),
        ),
      ),
      home: const StaffPerformanceScreen(),
    );
  }
}
