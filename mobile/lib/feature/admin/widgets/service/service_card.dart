import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../reject_dialog.dart';
import '../accept_dialog.dart';
import '../../screens/service_detail.dart';
import 'service_helpers.dart';
import 'package:provider/provider.dart';
import 'package:bengkel_online_flutter/feature/admin/providers/admin_service_provider.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    // Helper accessors
    final customerName = service.displayCustomerName;
    final vehicleName = service.displayVehicleName;
    final plate = service.displayVehiclePlate;
    final category = service.vehicle?.category ?? service.vehicle?.type ?? "Unknown";
    final scheduledDate = service.scheduledDate ?? DateTime.now();
    final serviceName = service.name;
    final id = service.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20), // 0.08 * 255
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryRed.withValues(alpha: 0.1),
                child: Text(
                  _getInitials(customerName),
                  style: AppTextStyles.labelBold(color: AppColors.primaryRed),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customerName,
                        style: AppTextStyles.labelBold()),
                    Text("ID: $id",
                        style: AppTextStyles.caption()),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(ServiceHelpers.formatDate(scheduledDate),
                      style: AppTextStyles.caption(color: AppColors.textPrimary)),
                  // Jika mau menampilkan info scheduled spesifik
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.statusPending.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text("Scheduled",
                        style: AppTextStyles.caption(color: AppColors.statusPending).copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  serviceName,
                  style: AppTextStyles.heading5(),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getVehicleBgColor(category)
                      .withValues(alpha: 0.2), 
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: AppTextStyles.caption(color: _getVehicleTextColor(category)).copyWith(fontWeight: FontWeight.w600),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Plat Nomor",
                      style:
                          AppTextStyles.caption()),
                  Text(plate,
                      style: AppTextStyles.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Builder(
                        builder: (ctx) => ElevatedButton(
                          onPressed: () => showRejectDialog(
                            ctx,
                            onConfirm: (reason, desc) {
                              context
                                  .read<AdminServiceProvider>()
                                  .declineServiceAsAdmin(
                                    service.id,
                                    reason: reason,
                                    reasonDescription: desc,
                                  );
                            },
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "Tolak",
                            style: AppTextStyles.buttonSmall(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => showAcceptDialog(
                          context,
                          onConfirm: () {
                            context
                                .read<AdminServiceProvider>()
                                .acceptServiceAsAdmin(service.id);
                          },
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "Terima",
                          style: AppTextStyles.buttonSmall(color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Type Motor",
                      style:
                          AppTextStyles.caption()),
                  Text(vehicleName,
                      style: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ServiceDetailPage(service: service)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      "Detail",
                      style: AppTextStyles.buttonSmall(color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Color _getVehicleBgColor(String? category) {
    switch (category?.toLowerCase()) {
      case "sepeda motor":
        return Colors.red.shade100;
      case "mobil":
        return Colors.orange.shade200;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getVehicleTextColor(String? category) {
    switch (category?.toLowerCase()) {
      case "sepeda motor":
        return Colors.red.shade700;
      case "mobil":
        return Colors.orange.shade800;
      default:
        return Colors.black87;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return "?";
    
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase(); // Just first letter if 1 word
    }
    
    // Take first letter of first 2 words
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
