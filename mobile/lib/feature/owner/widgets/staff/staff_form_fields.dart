import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color staffPrimaryColor = Color(0xFFD72B1C);

class StaffTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;

  const StaffTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.red,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        prefixIcon: Icon(
          icon,
          color: staffPrimaryColor,
          size: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: staffPrimaryColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: staffPrimaryColor, width: 2),
        ),
        filled: true,
        fillColor: const Color(0x66FFFFFF),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      style: GoogleFonts.poppins(color: Colors.black, fontSize: 12),
    );
  }
}

class StaffRoleDropdown extends StatelessWidget {
  final String selectedRole;
  final Function(String) onChanged;

  const StaffRoleDropdown({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedRole,
      onChanged: (v) => onChanged(v ?? selectedRole),
      items: const ['admin', 'mechanic']
          .map(
            (v) => DropdownMenuItem<String>(
              value: v,
              child: Text(
                v == 'admin' ? 'Admin (Kasir/Akuntan)' : 'Mekanik',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
          )
          .toList(),
      decoration: InputDecoration(
        labelText: "Role Karyawan",
        labelStyle: GoogleFonts.poppins(
          color: Colors.red,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(
          Icons.badge_outlined,
          color: staffPrimaryColor,
          size: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: staffPrimaryColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: staffPrimaryColor, width: 2),
        ),
        filled: true,
        fillColor: const Color(0x66FFFFFF),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
