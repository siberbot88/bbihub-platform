import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/feature/admin/screens/feedback.dart';
import 'package:bengkel_online_flutter/feature/admin/screens/voucher_page.dart';
import 'package:bengkel_online_flutter/feature/admin/screens/ubah_bahasa_page.dart';
import 'package:bengkel_online_flutter/feature/admin/screens/help_support_page.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/edit_user_screen.dart';
import 'package:bengkel_online_flutter/features/membership/presentation/premium_membership_screen.dart';
import 'package:bengkel_online_flutter/features/membership/presentation/membership_selection_screen.dart';
import 'package:bengkel_online_flutter/feature/admin/screens/live_chat_page.dart';
import 'package:bengkel_online_flutter/feature/admin/screens/report_list_screen.dart';

import 'profile_animations.dart';
import 'profile_menu_item.dart';

class ProfileMenuCard extends StatelessWidget {
  final double width;

  const ProfileMenuCard({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    final itemIconSize = (width * 0.06).clamp(18.0, 26.0);
    final itemFontSize = (width * 0.04).clamp(13.0, 16.0);
    const softSurface = Color(0xFFFFFFFF);

    return Transform.translate(
      offset: Offset(0, -width * 0.13),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        child: ProfileFadeInSlide(
          offsetY: 16,
          delayMs: 180,
          child: Card(
            elevation: 3,
            shadowColor: Colors.black26,
            color: softSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(width * 0.045),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: width * 0.02,
              ),
              child: Column(
                children: [
                  // Edit Profil User
                  _buildAnimatedItem(
                    context,
                    index: 0,
                    iconPath: "assets/icons/profile_edit.svg",
                    title: "Edit Profil User",
                    iconSize: itemIconSize,
                    fontSize: itemFontSize,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditUserScreen(),
                        ),
                      );
                    },
                  ),

                  const ProfileSoftDivider(),

                  // Membership / Langganan
                  _buildAnimatedItem(
                    context,
                    index: 1,
                    icon: Icons.card_membership_rounded,
                    title: "Langganan & Membership",
                    iconSize: itemIconSize,
                    fontSize: itemFontSize,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PremiumMembershipScreen(
                            isViewOnly: false,
                            onViewMembershipPackages: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const MembershipSelectionScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const ProfileSoftDivider(),

                  // Bahasa
                  _buildAnimatedItem(
                    context,
                    index: 2, // Check index order
                    iconPath: "assets/icons/bahasa.svg",
                    title: "Bahasa",
                    iconSize: itemIconSize,
                    fontSize: itemFontSize,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UbahBahasaPage(),
                        ),
                      );
                    },
                  ),
                  const ProfileSoftDivider(),
                  
                  // Live Chat
                   _buildAnimatedItem(
                    context,
                    index: 3,
                    icon: Icons.chat_bubble_outline_rounded,
                    title: "Live Chat",
                    iconSize: itemIconSize,
                    fontSize: itemFontSize,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LiveChatPage(),
                        ),
                      );
                    },
                  ),
                  const ProfileSoftDivider(),

                  // Aduan Aplikasi  
                  _buildAnimatedItem(
                    context,
                    index: 4,
                    icon: Icons.bug_report_outlined,
                    title: "Aduan Aplikasi",
                    iconSize: itemIconSize,
                    fontSize: itemFontSize,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportListScreen(),
                        ),
                      );
                    },
                  ),
                  const ProfileSoftDivider(),

                  // Bantuan & Dukungan
                  _buildAnimatedItem(
                    context,
                    index: 5,
                    iconPath: "assets/icons/help.svg",
                    title: "Bantuan & Dukungan",
                    iconSize: itemIconSize,
                    fontSize: itemFontSize,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportPage(),
                        ),
                      );
                    },
                  ),
                  const ProfileSoftDivider(),

                  // Ganti Password
                  _buildAnimatedItem(
                    context,
                    index: 4,
                    iconPath: "assets/icons/password.svg",
                    title: "Ganti Password",
                    iconSize: itemIconSize,
                    fontSize: itemFontSize,
                    onTap: () {
                      Navigator.pushNamed(context, '/changePassword');
                    },
                  ),
                  const ProfileSoftDivider(),

                  // Voucher
                  _buildAnimatedItem(
                    context,
                    index: 5,
                    iconPath: "assets/icons/voucher.svg",
                    title: "Voucher",
                    iconSize: itemIconSize,
                    fontSize: itemFontSize,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VoucherPage(),
                        ),
                      );
                    },
                  ),
                  const ProfileSoftDivider(),

                  // Umpan Balik
                  _buildAnimatedItem(
                    context,
                    index: 6,
                    iconPath: "assets/icons/feedback.svg",
                    title: "Umpan Balik",
                    iconSize: itemIconSize,
                    fontSize: itemFontSize,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FeedbackPage(),
                        ),
                      );
                    },
                  ),
                  const ProfileSoftDivider(),

                  // Logout
                  _buildAnimatedItem(
                    context,
                    index: 7,
                    iconPath: "assets/icons/logout.svg",
                    title: "Keluar",
                    isLogout: true,
                    iconSize: itemIconSize,
                    fontSize: itemFontSize,
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(
    BuildContext context, {
    required int index,
    String? iconPath,
    IconData? icon,
    required String title,
    required double iconSize,
    required double fontSize,
    VoidCallback? onTap,
    bool isLogout = false,
  }) {
    final delayMs = 80 * index;
    return ProfileFadeInSlide(
      offsetY: 10,
      delayMs: delayMs,
      child: ProfileMenuItem(
        iconPath: iconPath,
        icon: icon,
        title: title,
        isLogout: isLogout,
        onTap: onTap,
        iconSize: iconSize,
        fontSize: fontSize,
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Keluar",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          "Apakah Anda yakin ingin keluar?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "Batal",
              style: GoogleFonts.poppins(),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
            child: Text(
              "Ya",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
