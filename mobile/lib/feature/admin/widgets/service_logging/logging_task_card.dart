import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'logging_helpers.dart';
import '../../screens/service_detail_page.dart';
import '../../screens/invoice_form_screen.dart';
import '../../screens/cash_payment_screen.dart';
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
      // Check invoice status
      final invoice = service.invoice;
      final isInvoiceCreated = invoice != null;
      final isPaid = isInvoiceCreated && (invoice['status'] == 'paid');

      if (isPaid) {
        actionButton = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green),
          ),
          child: Text("Lunas", style: AppTextStyles.caption(color: Colors.green)),
        );
      } else if (isInvoiceCreated) {
        // Invoice created -> Show "Bayar"
        actionButton = ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CashPaymentScreen(
                  invoiceId: invoice['id'],
                  total: double.tryParse(invoice['total'].toString()) ?? 0.0,
                  invoiceCode: invoice['invoice_code'] ?? '',
                  service: service,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          ),
          child: Text("Bayar Tagihan",
              style: AppTextStyles.buttonSmall(color: Colors.white).copyWith(fontSize: 12)),
        );
      } else {
        // No invoice -> Show "Buat Tagihan"
        actionButton = ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InvoiceFormScreen(
                  serviceId: service.id,
                  serviceType: service.type ?? 'on-site',
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          ),
          child: Text("Buat Tagihan",
              style: AppTextStyles.buttonSmall(color: Colors.white).copyWith(fontSize: 12)),
        );
      }
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
