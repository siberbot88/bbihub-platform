import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_header.dart';
import '../widgets/reject_dialog.dart';
import '../widgets/accept_dialog.dart';
import 'package:provider/provider.dart';
import 'package:bengkel_online_flutter/feature/admin/providers/admin_service_provider.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';
import '../widgets/service/service_helpers.dart';

class ServiceDetailPage extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailPage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final textScale = mq.textScaler.scale(1.0).clamp(0.9, 1.15);
    double s(double size) => (size * textScale);

    // Helpers
    final id = service.id;
    final customerName = service.displayCustomerName;
    final scheduledDate = service.scheduledDate ?? DateTime.now();
    final dateOrder = service.createdAt ?? DateTime.now();
    final vehicleName = service.displayVehicleName;
    final plate = service.displayVehiclePlate;
    final category = service.vehicle?.category ?? service.vehicle?.type ?? "Unknown";
    final phone = service.customer?.phoneNumber ?? '-'; // Asumsi ada phone number di customer atau di mana saja
    final address = service.customer?.address ?? '-'; // Asumsi ada address
    final desc = service.reasonDescription ?? service.description ?? '-';

    Widget divider() => Divider(
          color: Colors.grey.shade300,
          thickness: 1,
          height: 24,
        );

    return Scaffold(
      appBar: const CustomHeader(
        title: "Service Detail",
        showBack: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF510707), Color(0xFF9B0D0D), Color(0xFFB70F0F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔹 User Info
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage(
                                    "https://i.pravatar.cc/150?img=$id",
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customerName,
                                        style: GoogleFonts.poppins(
                                          fontSize: s(18),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        "ID: $id",
                                        style: GoogleFonts.poppins(
                                          fontSize: s(13),
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("Date order",
                                        style: TextStyle(
                                            fontSize: s(12),
                                            color: Colors.grey[600])),
                                    Text(ServiceHelpers.formatDate(dateOrder),
                                        style: GoogleFonts.poppins(
                                            fontSize: s(14),
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),

                            divider(),

                            // 🔹 Foto Kendaraan
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.asset(
                                    "assets/image/motorbeat.png",
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            divider(),

                            // 🔹 Model & Jadwal
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Model Kendaraan",
                                          style: TextStyle(
                                              fontSize: s(12),
                                              color: Colors.grey[600])),
                                      Text(vehicleName,
                                          style: GoogleFonts.poppins(
                                              fontSize: s(15),
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("Penjadwalan",
                                          style: TextStyle(
                                              fontSize: s(12),
                                              color: Colors.grey[600])),
                                      Text("${ServiceHelpers.formatDate(scheduledDate)}", // Simplified for now
                                          textAlign: TextAlign.right,
                                          style: GoogleFonts.poppins(
                                              fontSize: s(15),
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            divider(),

                            // 🔹 Plat & Jenis
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Plat Nomor",
                                          style: TextStyle(
                                              fontSize: s(12),
                                              color: Colors.grey[600])),
                                      Text(plate,
                                          style: GoogleFonts.poppins(
                                              fontSize: s(15),
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("Jenis Kendaraan",
                                          style: TextStyle(
                                              fontSize: s(12),
                                              color: Colors.grey[600])),
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFBC7C7),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          category,
                                          style: GoogleFonts.poppins(
                                            fontSize: s(13),
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF6E1313),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            divider(),

                            // 🔹 Kategori & Telepon
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Kategori Servis",
                                          style: TextStyle(
                                              fontSize: s(12),
                                              color: Colors.grey[600])),
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200
                                              .withAlpha(153),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          service.categoryName ?? "Pemeliharaan",
                                          style: GoogleFonts.poppins(
                                            fontSize: s(13),
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFFD42525),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("No. Telepon",
                                          style: TextStyle(
                                              fontSize: s(12),
                                              color: Colors.grey[600])),
                                      Text(phone,
                                          style: GoogleFonts.poppins(
                                              fontSize: s(14),
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            divider(),

                            // 🔹 Alamat
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Alamat",
                                    style: TextStyle(
                                        fontSize: s(12),
                                        color: Colors.grey[600])),
                                Text(
                                  address,
                                  style: GoogleFonts.poppins(
                                    fontSize: s(14),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            divider(),

                            // 🔹 Keluhan
                            Text("Keluhan",
                                style: GoogleFonts.poppins(
                                    fontSize: s(14),
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.red.shade300),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.red.shade50,
                              ),
                              child: Text(
                                desc,
                                style: TextStyle(fontSize: s(13)),
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),

      // 🔹 Tombol bawah tetap
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: () => showRejectDialog(
                    context,
                    onConfirm: (reason, desc) {
                      context.read<AdminServiceProvider>().declineServiceAsAdmin(
                            service.id,
                            reason: reason,
                            reasonDescription: desc,
                          );
                      Navigator.pop(context); // Close detail page after action? Maybe better to keep open or refresh. 
                      // User flow usually expects going back if item status changes heavily.
                      // Let's pop for now as it moves to history.
                      Navigator.pop(context);
                    },
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    "Tolak",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: () => showAcceptDialog(
                    context,
                    onConfirm: () {
                      context
                          .read<AdminServiceProvider>()
                          .acceptServiceAsAdmin(service.id);
                      Navigator.pop(context); // Close detail page
                    },
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    "Terima",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
