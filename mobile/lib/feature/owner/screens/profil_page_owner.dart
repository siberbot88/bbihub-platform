import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/core/models/user.dart';
import 'package:bengkel_online_flutter/core/models/workshop.dart';

import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_menu_card.dart';

class ProfilePageOwner extends StatelessWidget {
  const ProfilePageOwner({super.key});

  String _getInitials(String name) {
    if (name.isEmpty) return 'B';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts.first.isNotEmpty ? parts.first[0] : '') +
          (parts.last.isNotEmpty ? parts.last[0] : '');
    } else if (parts.first.isNotEmpty) {
      return parts.first[0];
    }
    return 'B';
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

    final Workshop? workshop =
        (user.workshops != null && user.workshops!.isNotEmpty)
            ? user.workshops!.first
            : null;

    final String photoUrl = user.photo ?? '';
    final String workshopName = workshop?.name ?? user.name;
    final String initials = _getInitials(workshopName);
    final String workshopEmail = workshop?.email ?? user.email;
    final String roleName = _formatRole(user.role);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                ProfileHeader(
                  width: width,
                  photoUrl: photoUrl,
                  workshopName: workshopName,
                  initials: initials,
                  workshopEmail: workshopEmail,
                  roleName: roleName,
                  workshop: workshop,
                ),
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