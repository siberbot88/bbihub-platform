import 'package:flutter/material.dart';

String formatCurrency(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idx = s.length - i;
    buf.write(s[i]);
    if (idx > 1 && idx % 3 == 1) {
      buf.write('.');
    }
  }
  return buf.toString();
}

class ReportRangeChip extends StatelessWidget {
  const ReportRangeChip({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
    this.highlight = false,
  });

  final String text;
  final bool selected;
  final bool highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const kDanger = Color(0xFFDC2626);
    
    final bg = selected
        ? (highlight ? const Color(0xFFF59E0B) : Colors.white)
        : const Color(0xFF7F0F0F);
    final fg =
        selected ? (highlight ? Colors.white : kDanger) : Colors.white70;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 44,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
