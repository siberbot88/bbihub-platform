import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_header.dart';
import '../widgets/assign_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';   
import 'package:provider/provider.dart';
import 'package:bengkel_online_flutter/feature/admin/providers/admin_service_provider.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:intl/intl.dart';          


class ServicePendingDetail extends StatelessWidget {
  final ServiceModel service;

  const ServicePendingDetail({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFFDC2626);
    
    // Helpers
    final id = service.id;
    final customerName = service.displayCustomerName;
    final scheduledDate = service.scheduledDate;
    final vehicleName = service.displayVehicleName;
    final plate = service.displayVehiclePlate;
    final category = service.vehicle?.category ?? service.vehicle?.type ?? "Unknown";
    final phone = service.customer?.phoneNumber ?? '-';
    final address = service.customer?.address ?? '-';
    final desc = service.complaint ?? service.request ?? service.description ?? '-';
    final status = service.status;

    return Scaffold(
      appBar: const CustomHeader(
        title: "Tugas",
        showBack: true,
      ),
      backgroundColor: mainColor,
      
       // ✅ Tombol sticky di bawah
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white, // 🔹 Background belakang tombol
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton.icon(
              onPressed: () {
                showTechnicianSelectDialog(
                  context,
                  onConfirm: (mechanicUuid, mechanicName) {
                    context.read<AdminServiceProvider>().assignMechanicAsAdmin(
                      service.id,
                      mechanicUuid,
                    ).then((_) {
                       ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Service berhasil diassign ke $mechanicName",
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context); // Close detail on success
                    }).catchError((e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Gagal assign: $e",
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                    });
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor, // 🔹 Warna tombol merah (#DC2626)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
                shadowColor: Colors.black.withAlpha(38),
              ),
              icon: SvgPicture.asset(
                'assets/icons/assign.svg', // 🔹 Ikon SVG lokal
                height: 22,
                width: 22,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              label: Text(
                "Tetapkan Mekanik",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 User + Date Order
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(
                      "https://i.pravatar.cc/150?img=$id",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customerName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "ID: $id",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Tanggal order",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        scheduledDate != null ? _formatDate(scheduledDate) : "-",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 🔹 Foto Kendaraan (square 1:1)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 1, // square
                    child: Image.asset(
                      "assets/image/motorbeat.png",
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Detail Kendaraan
              _detailRow(
                "Jenis Kendaraan",
                category,
                custom: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: mainColor.withAlpha(38),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: mainColor,
                    ),
                  ),
                ),
              ),
              _detailRow("Model Kendaraan", vehicleName),
              _detailRow(
                "Penjadwalan",
                scheduledDate != null ? _formatDate(scheduledDate) : '-',
              ),
              _detailRow("Plat Nomor", plate),
              _detailRow(
                "Status",
                status,
                custom: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(102),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (status ?? "PENDING").toString().toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
              _detailRow("No. Telepon", phone),
              _detailRow(
                "Alamat",
                address,
              ),

              const SizedBox(height: 18),

               // 🔹 Keluhan
             Center(
             child : Text(
                "Keluhan",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,  
                ),
              ),
             ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: mainColor, width: 1),
                  borderRadius: BorderRadius.circular(8),
                  color: mainColor.withAlpha(13),
                ),
                child: Text(
                  desc,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Helper Row Info
  Widget _detailRow(String label, String? value, {Widget? custom}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.centerRight,
              child: custom ??
                  Text(
                    value ?? "-",
                    textAlign: TextAlign.right,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Ags", "Sep", "Okt", "Nov", "Des"
    ];
    return "${d.day} ${months[d.month - 1]} ${d.year}";
  }
}
