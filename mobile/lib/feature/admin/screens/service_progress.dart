import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_header.dart';
import 'package:flutter_svg/flutter_svg.dart';          


class ServiceProgressDetail extends StatelessWidget {
  final Map<String, dynamic> task;

  const ServiceProgressDetail({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final DateTime? orderDate = task['date'] is DateTime ? task['date'] : null;
    const mainColor = Color(0xFFDC2626);

    // 🔹 Tentukan jenis kendaraan
    final String motorType =
        (task['motorType']?.toString().toLowerCase() ?? "motor") == "mobil"
            ? "MOBIL"
            : "SEPEDA MOTOR";

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              // 1. Teks pesan yang ingin ditampilkan
              content: Text('Menunggu teknisi untuk menandai sebagai tugas selesai'),
              // 2. Mengatur berapa lama pesan tampil
              duration: Duration(seconds: 3),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9A9999),
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
          "Menunggu Mekanik Selesai",
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
                      "https://i.pravatar.cc/150?img=${task['id']}",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['user'] ?? "-",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "ID: ${task['id']}",
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
                        orderDate != null ? _formatDate(orderDate) : "-",
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
                motorType,
                custom: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: mainColor.withAlpha(38),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    motorType,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: mainColor,
                    ),
                  ),
                ),
              ),
              _detailRow("Model Kendaraan", task['motor']),
              _detailRow(
                "Penjadwalan",
                "${task['time']} : ${orderDate != null ? _formatDate(orderDate) : '-'}",
              ),
              _detailRow("Plat Nomor", task['plate']),
              _detailRow(
                "Status",
                task['status'],
                custom: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(38),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (task['status'] ?? "PROSES").toString().toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ),
              _detailRow("No. Telepon", "08956733xxx"),
              _detailRow(
                "Alamat",
                "Jl. Medokan Ayu No.13, Kecamatan Gunung Anyar",
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
                  task['desc'] ?? "Penggantian bantalan rem lengkap dan kalibrasi sistem untuk unit excavator",
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
