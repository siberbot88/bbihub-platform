import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileSoftDivider extends StatelessWidget {
  const ProfileSoftDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: MediaQuery.of(context).size.width * 0.16,
      endIndent: MediaQuery.of(context).size.width * 0.04,
      color: Colors.grey.withAlpha(64), // 0.25 * 255
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final String? iconPath;
  final IconData? icon;
  final String title;
  final bool isLogout;
  final VoidCallback? onTap;
  final double iconSize;
  final double fontSize;

  const ProfileMenuItem({
    super.key,
    this.iconPath,
    this.icon,
    required this.title,
    this.isLogout = false,
    this.onTap,
    this.iconSize = 28,
    this.fontSize = 16,
  }) : assert(iconPath != null || icon != null, 'Either iconPath or icon must be provided');

  @override
  Widget build(BuildContext context) {
    final isDarkLogout = isLogout;
    final primaryColor = isDarkLogout ? const Color(0xFFB70F0F) : const Color(0xFF9B0D0D);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
            vertical: 6,
          ),
          child: ListTile(
            minLeadingWidth: 0,
            contentPadding: EdgeInsets.zero,
            leading: icon != null 
              ? Icon(icon, size: iconSize, color: primaryColor)
              : _buildIcon(
                  iconPath!,
                  size: iconSize,
                  color: primaryColor,
                ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                color: isDarkLogout
                    ? const Color(0xFFB70F0F)
                    : const Color(0xFF111827),
                fontWeight: isDarkLogout ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: fontSize * 0.82,
              color: Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String path, {Color? color, double size = 24}) {
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: size,
        height: size,
        colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      );
    }
    return Image.asset(path, width: size, height: size, color: color);
  }
}
