import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final String initials;
  final double radius;
  final Color color;

  const ProfileAvatar({
    super.key,
    required this.photoUrl,
    required this.initials,
    required this.radius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = (photoUrl != null &&
        photoUrl!.isNotEmpty &&
        (photoUrl!.startsWith('http') || photoUrl!.startsWith('https')));

    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      backgroundImage: hasImage ? NetworkImage(photoUrl!) : null,
      child: hasImage
          ? null
          : Text(
              initials.toUpperCase(),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: radius * 0.9,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
