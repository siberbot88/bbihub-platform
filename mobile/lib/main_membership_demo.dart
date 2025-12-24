import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/membership/presentation/premium_membership_screen.dart';
import 'features/membership/presentation/membership_selection_screen.dart'; // Import this

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFDC2626)),
        useMaterial3: true,
      ),
      // Set initial route to PremiumMembershipScreen for demo
      home: PremiumMembershipScreen(
        isViewOnly: false,
        onViewMembershipPackages: () {
          //     builder: (context) => MembershipPackagesScreen(),
          //   ),
          // );
          debugPrint('🎯 Navigate to Membership Packages');
        },
        onContinueFreeVersion: () {
          // TODO: Navigasi ke halaman utama aplikasi (home/dashboard)
          // Contoh:
          // Navigator.pushReplacementNamed(context, '/home');
          debugPrint('✨ Continue with free version');
        },
      ),
    );
  }
}
