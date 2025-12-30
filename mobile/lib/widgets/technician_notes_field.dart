import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TechnicianNotesField extends StatelessWidget {
  final TextEditingController controller;

  const TechnicianNotesField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextField(
          controller: controller, // Use the controller!
          maxLines: null,
          minLines: 5,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFF111827),
          ),
          decoration: InputDecoration(
            hintText: "Catatan untuk pelanggan atau internal",
            hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Text(
              "Opsional",
              style: GoogleFonts.inter(
                fontSize: 10,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
