import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvoiceCustomerHeader extends StatelessWidget {
  final Map<String, dynamic> task;

  const InvoiceCustomerHeader({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime? orderDate =
        task['date'] is DateTime ? task['date'] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(
            "https://i.pravatar.cc/150?img=${task['id'] ?? 1}",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task['user'] ?? "Prabowo",
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text("ID: ${task['id'] ?? '4589930272'}",
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey[700])),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("Tanggal order",
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey[700])),
            Text(
              orderDate != null
                  ? _formatDate(orderDate)
                  : "2 September 2025",
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Ags",
      "Sep",
      "Okt",
      "Nov",
      "Des"
    ];
    return "${d.day} ${months[d.month - 1]} ${d.year}";
  }
}
