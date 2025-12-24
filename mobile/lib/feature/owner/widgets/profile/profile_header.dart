import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/edit_profile_page.dart';
import 'package:bengkel_online_flutter/core/models/workshop.dart';
import 'profile_animations.dart';
import 'profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final double width;
  final String photoUrl;
  final String workshopName;
  final String initials;
  final String workshopEmail;
  final String roleName;
  final Workshop? workshop;

  const ProfileHeader({
    super.key,
    required this.width,
    required this.photoUrl,
    required this.workshopName,
    required this.initials,
    required this.workshopEmail,
    required this.roleName,
    this.workshop,
  });

  @override
  Widget build(BuildContext context) {
    final bottomRadius = width * 0.08;
    final avatarRadius = ((width * 0.15)).clamp(46.0, 72.0);
    final titleFontSize = (width * 0.045).clamp(16.0, 20.0);
    final nameFontSize = (width * 0.048).clamp(15.0, 22.0);
    final usernameFontSize = (width * 0.032).clamp(11.0, 14.0);
    final roleFontSize = (width * 0.032).clamp(11.0, 14.0);
    final editFontSize = (width * 0.04).clamp(12.0, 16.0);

    const primaryInner = Color(0xFF9B0D0D);
    const primaryOuter = Color(0xFFB70F0F);

    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(bottomRadius),
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryInner, primaryOuter],
            stops: [0.29, 0.79],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              top: width * 0.06,
              bottom: width * 0.18, // space buat card overlap
              left: width * 0.05,
              right: width * 0.05,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                ProfileFadeInSlide(
                  offsetY: 14,
                  delayMs: 0,
                  child: Text(
                    "Profile",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                SizedBox(height: width * 0.04),

                // Avatar
                ProfileScaleIn(
                  delayMs: 80,
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: Colors.white.withAlpha(38), // 0.15 * 255
                    child: ProfileAvatar(
                      photoUrl: photoUrl,
                      initials: initials,
                      radius: avatarRadius - 4,
                      color: primaryInner,
                    ),
                  ),
                ),
                SizedBox(height: width * 0.03),

                // Workshop Name
                ProfileFadeInSlide(
                  offsetY: 12,
                  delayMs: 160,
                  child: Text(
                    workshopName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: width * 0.008),

                // Email
                ProfileFadeInSlide(
                  offsetY: 10,
                  delayMs: 220,
                  child: Text(
                    workshopEmail,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withAlpha(204), // 0.8 * 255
                      fontSize: usernameFontSize,
                    ),
                  ),
                ),
                SizedBox(height: width * 0.02),

                // Role & Edit
                ProfileFadeInSlide(
                  offsetY: 10,
                  delayMs: 280,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.03,
                          vertical: width * 0.008,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(46), // 0.18 * 255
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          roleName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: roleFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: width * 0.03),
                      // Edit button
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.04,
                            vertical: width * 0.01,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                              color: Colors.white.withAlpha(102), // 0.4 * 255
                              width: 0.8,
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (workshop != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfilePage(workshop: workshop!),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Data workshop belum tersedia')),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                        ),
                        label: Text(
                          "Edit",
                          style: GoogleFonts.poppins(
                            fontSize: editFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
