import 'package:flutter/material.dart';

class WorkDetailPanel extends StatelessWidget {
  final Widget child;
  const WorkDetailPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class WorkSectionTitle extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const WorkSectionTitle({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor = const Color(0xFFDC2626), // Default danger color
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: iconColor),
      const SizedBox(width: 8),
      Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ]);
  }
}
