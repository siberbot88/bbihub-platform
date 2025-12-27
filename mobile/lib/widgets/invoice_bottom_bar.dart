import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/currency_idr.dart';

class InvoiceBottomBar extends StatelessWidget {
  final double subtotal;
  final VoidCallback onSend;

  const InvoiceBottomBar({
    super.key,
    required this.subtotal,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 6,
            spreadRadius: -1,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Totals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Tagihan",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Subtotal: ${CurrencyIdr.format(subtotal)}",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF6B7280), // secondary text
                      ),
                    ),
                  ],
                ),
                // Animated Switcher for total
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                     return FadeTransition(opacity: animation, child: 
                       SlideTransition(
                         position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
                         child: child
                       )
                     );
                  },
                  child: Text(
                    CurrencyIdr.format(subtotal),
                    key: ValueKey<double>(subtotal),
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827), // gray-900
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Buttons
            Row(
              children: [
                 // Batalkan (optional secondary button as per image)
                 //Wait, image shows "Batalkan" text button or similar? 
                 // Image Footer: "Batalkan" (gray button) "Kirim Invoice" (red). 
                 // HTML Screen 1 footer grid grid-cols-3.
                 Expanded(
                   flex: 1,
                   child: TextButton(
                     onPressed: () => Navigator.pop(context),
                     style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: const Color(0xFF6B7280),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     ),
                     child: Text(
                       "Batalkan",
                       style: GoogleFonts.inter(
                         fontSize: 16,
                         fontWeight: FontWeight.w500,
                       ),
                     ),
                   ),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   flex: 2,
                   child: ElevatedButton(
                     onPressed: onSend,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: const Color(0xFFEF4444),
                       padding: const EdgeInsets.symmetric(vertical: 16),
                       elevation: 4,
                       shadowColor: const Color(0xFFEF4444).withOpacity(0.4),
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(12),
                       ),
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text(
                           "Kirim Invoice",
                           style: GoogleFonts.inter(
                             fontSize: 16,
                             fontWeight: FontWeight.w600,
                             color: Colors.white,
                           ),
                         ),
                         const SizedBox(width: 8),
                         const Icon(Icons.send, size: 20, color: Colors.white),
                       ],
                     ),
                   ),
                 ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
