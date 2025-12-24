import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/core/models/user.dart';

// Import widgets from owner feature (reusing them)
import 'package:bengkel_online_flutter/feature/owner/widgets/profile/profile_header.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/profile/profile_menu_card.dart';

class ProfilePageAdmin extends StatelessWidget {
  const ProfilePageAdmin({super.key});

  String _getInitials(String name) {
    if (name.isEmpty) return 'A';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts.first.isNotEmpty ? parts.first[0] : '') +
          (parts.last.isNotEmpty ? parts.last[0] : '');
    } else if (parts.first.isNotEmpty) {
      return parts.first[0];
    }
    return 'A';
  }

  String _formatRole(String role) {
    if (role.isEmpty) return 'User';
    return role[0].toUpperCase() + role.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final User? user = auth.user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F4F5),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF9B0D0D)),
        ),
      );
    }

    final String photoUrl = user.photo ?? '';
    final String adminName = user.name;
    final String initials = _getInitials(adminName);
    final String adminEmail = user.email;
    final String roleName = _formatRole(user.role);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Reusing ProfileHeader from Owner feature
                // Passing adminName as workshopName since the layout is compatible
                ProfileHeader(
                  width: width,
                  photoUrl: photoUrl,
                  workshopName: adminName,
                  initials: initials,
                  workshopEmail: adminEmail,
                  roleName: roleName,
                ),
                // Reusing ProfileMenuCard from Owner feature
                ProfileMenuCard(width: width),
                SizedBox(height: width * 0.02),
              ],
            ),
          );
        },
      ),
    );
  }
}