import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'logging_helpers.dart';
import '../../screens/service_detail_page.dart'; // Correct import
// Imports from deleted files removed
import 'package:bengkel_online_flutter/core/models/service.dart';

class LoggingTaskCard extends StatelessWidget {
  final ServiceModel service;

  const LoggingTaskCard({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    // Map API status to UI status colors
    // Statuses: pending, in_progress, completed, canceled
    final status = service.status ?? 'Pending';

    if (status.toLowerCase() == "completed") {
      statusColor = AppColors.statusCompleted;
    } else if (status.toLowerCase() == "in_progress" || status.toLowerCase() == "on_process") {
      statusColor = AppColors.statusInProgress;
    } else if (status.toLowerCase() == "pending") {
      statusColor = AppColors.statusPending; // Pending mechanic assignment
    } else {
      statusColor = AppColors.textSecondary;
    }

    Widget actionButton;

    // Logic for buttons based on status
    if (status.toLowerCase() == 'pending') {
      actionButton = ElevatedButton(
        onPressed: () {
           Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ServiceDetailPage(service: service),
              ));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        ),
        child: Text("Tetapkan Mekanik",
            style: AppTextStyles.buttonSmall(color: Colors.white).copyWith(fontSize: 12)),
      );
    } else if (status.toLowerCase() == 'in_progress' || status.toLowerCase() == "on_process") {
      actionButton = ElevatedButton(
        onPressed: () {
           Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ServiceDetailPage(service: service),
              ));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.statusInProgress,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        ),
        child: Text("Lihat Detail",
            style: AppTextStyles.buttonSmall(color: Colors.white).copyWith(fontSize: 12)),
      );
    } else if (status.toLowerCase() == 'completed') {
      actionButton = ElevatedButton(
        onPressed: () {
           Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ServiceDetailPage(service: service),
              ));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.statusCompleted,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        ),
        child: Text("Lihat Detail",
            style: AppTextStyles.buttonSmall(color: Colors.white).copyWith(fontSize: 12)),
      );
    } else {
      actionButton = const SizedBox.shrink();
    }

    final scheduledDate = service.scheduledDate ?? DateTime.now();
    final timeStr = "${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(26), // Increased opacity for better visibility
              blurRadius: 8,
              offset: const Offset(0, 2)),
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(status,
                    style: AppTextStyles.caption(color: statusColor).copyWith(fontWeight: FontWeight.w600)),
              ),
              Text(
                  "${LoggingHelpers.formatDate(scheduledDate)} • $timeStr",
                  style: AppTextStyles.caption()),
            ],
          ),
          const SizedBox(height: 8),
          Text(service.name,
              style: AppTextStyles.heading5()),
          const SizedBox(height: 4),
          Text(service.complaint ?? service.request ?? service.description ?? '-',
              style: AppTextStyles.bodyMedium(color: AppColors.textPrimary), 
              maxLines: 2, 
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.two_wheeler, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text("${service.displayVehicleName}  •  ${service.displayVehiclePlate}",
                  style: AppTextStyles.caption()),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/150?img=${service.id}")),
                  const SizedBox(width: 8),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.displayCustomerName,
                          style: AppTextStyles.labelBold()),
                      Text("ID: ${service.id}",
                          style: AppTextStyles.caption()),
                    ],
                  ),
                ],
              ),
              actionButton,
            ],
          ),
        ],
      ),
    );
  }
}
