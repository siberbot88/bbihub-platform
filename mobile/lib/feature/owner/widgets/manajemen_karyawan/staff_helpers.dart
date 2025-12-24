import 'package:flutter/material.dart';

String staffInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
}

Color staffAvatarBg(String seed) {
  final hash = seed.codeUnits.fold<int>(0, (p, c) => p + c);
  final hue = (hash % 360).toDouble();
  return HSLColor.fromAHSL(1, hue, 0.45, 0.62).toColor();
}
