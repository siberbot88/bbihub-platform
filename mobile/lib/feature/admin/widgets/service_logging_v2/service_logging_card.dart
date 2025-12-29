import 'package:flutter/material.dart';
import '../../../../core/models/service.dart';
import '../../../../core/theme/app_colors.dart';

class ServiceLoggingCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const ServiceLoggingCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = (service.status ?? '').toLowerCase();
    
    Color statusColor;
    String statusLabel;
    
    if (status.contains('progress')) {
      statusColor = Colors.orange;
      statusLabel = 'In Progress';
    } else if (status == 'completed') {
      statusColor = Colors.grey;
      statusLabel = 'Completed';
    } else if (status == 'ready') {
      statusColor = Colors.green;
      statusLabel = 'Ready';
    } else {
      statusColor = Colors.blue;
      statusLabel = 'Pending';
    }

    final timeLabel = _getTimeLabel(service.scheduledDate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2F1F1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.grey[800]!.withOpacity(0.5) : Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${service.id.substring(0, 4).toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryRed,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        service.name ?? 'Untitled Service',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    timeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Reg: ${service.displayVehiclePlate} • ${service.categoryName ?? 'Service'}',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: isDark ? Colors.grey[800]!.withOpacity(0.5) : Colors.grey[100],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: Text(
                    service.displayCustomerName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    service.displayCustomerName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor.withOpacity(0.9),
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

  String _getTimeLabel(DateTime? serviceDate) {
    if (serviceDate == null) return 'N/A';
    
    final now = DateTime.now();
    if (serviceDate.day == now.day && serviceDate.month == now.month && serviceDate.year == now.year) {
      final hour = serviceDate.hour % 12 == 0 ? 12 : serviceDate.hour % 12;
      final period = serviceDate.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:${serviceDate.minute.toString().padLeft(2, '0')} $period';
    } else if (serviceDate.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return '${serviceDate.day}/${serviceDate.month}';
    }
  }
}
