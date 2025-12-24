import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvoiceServiceInfo extends StatelessWidget {
  final Map<String, dynamic> task;
  final Color mainColor;

  const InvoiceServiceInfo({
    super.key,
    required this.task,
    required this.mainColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Model Kendaraan",
                style:
                    GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(task['model'] ?? "BEAT2012",
                style:
                    GoogleFonts.poppins(color: Colors.blueAccent, fontSize: 13)),
            const SizedBox(height: 8),
            Text("Plat Nomor",
                style:
                    GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(task['plate'] ?? "SU 814 NTO",
                style: GoogleFonts.poppins(fontSize: 13)),
          ]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Penjadwalan",
                style:
                    GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(task['jadwal'] ?? "8:00 - 10:00 AM : 05/08/2025",
                style: GoogleFonts.poppins(fontSize: 13)),
            const SizedBox(height: 8),
            Text("Jenis Kendaraan",
                style:
                    GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFE5E5),
                  borderRadius: BorderRadius.circular(14)),
              child: Text(task['jenis'] ?? "Sepeda Motor",
                  style: GoogleFonts.poppins(
                      color: mainColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ],
    );
  }
}
