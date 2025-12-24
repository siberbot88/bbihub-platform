//reject
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showRejectDialog(BuildContext context, {required Function(String, String) onConfirm}) {
  final List<String> reasons = [
    "Harga tidak sesuai",
    "Jadwal bentrok",
    "Lokasi terlalu jauh",
    "Lainnya"
  ];
  String? selectedReason;
  final TextEditingController notesController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text("Tolak Pesanan Servis",
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[800])),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      "Silakan pilih alasan penolakan agar user mendapatkan informasi yang jelas",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Dropdown alasan
                  Text("Alasan Penolakan",
                      style: GoogleFonts.poppins(fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedReason,
                    items: reasons
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => selectedReason = val),
                    decoration: InputDecoration(
                      hintText: "Pilih alasan anda",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Notes
                  Text("Additional Notes",
                      style: GoogleFonts.poppins(fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Write in here ...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: Text("Batalkan",
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: Colors.black)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Tutup popup pertama
                            showConfirmRejectDialog(context, onConfirm, selectedReason ?? "Lainnya", notesController.text); // Muncul popup kedua
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text("Lanjutkan",
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

void showConfirmRejectDialog(
  BuildContext context,
  Function(String, String) onConfirm,
  String reason,
  String description,
) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.close_rounded, size: 50, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                "Apakah anda yakin untuk menolak permintaan service ini ?",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: Text("Batalkan",
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // close confirm dialog
                        onConfirm(reason, description);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Yakin",
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}