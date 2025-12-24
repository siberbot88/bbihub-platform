import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String iconPath;
  final bool isPassword;
  final int maxLines;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final bool? obscureState;
  final VoidCallback? onToggleObscure;
  final FormFieldValidator<String>? validator;

  const RegisterTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.iconPath,
    this.isPassword = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.obscureState,
    this.onToggleObscure,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      obscureText: isPassword ? (obscureState ?? true) : false,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            iconPath,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
          ),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  (obscureState ?? true) ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFFD72B1C),
                ),
                onPressed: onToggleObscure,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD72B1C), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD72B1C), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
        errorStyle: const TextStyle(fontSize: 10, color: Colors.orange),
        filled: true,
        fillColor: const Color(0x66FFFFFF),
      ),
      style: GoogleFonts.poppins(color: Colors.black, fontSize: 12),
    );
  }
}
