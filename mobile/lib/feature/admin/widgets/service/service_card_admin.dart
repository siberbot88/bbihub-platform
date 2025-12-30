import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ServiceCardAdmin extends StatelessWidget {
  final String customerName;
  final String vehicleName;
  final String licensePlate;
  final String serviceType;
  final String time;
  final String status; // 'Menunggu', 'Proses', 'Selesai'
  final VoidCallback? onTap;

  final bool isToday; // New param

  const ServiceCardAdmin({
    super.key,
    required this.customerName,
    required this.vehicleName,
    required this.licensePlate,
    required this.serviceType,
    required this.time,
    required this.status,
    this.isToday = true, // Default true for backward compat if needed
    this.onTap,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return const Color(0xFFFFF4CC); // Light yellow
      case 'proses':
        return const Color(0xFFE3F2FD); // Light blue
      case 'selesai':
        return const Color(0xFFE8F5E9); // Light green
      default:
        return Colors.grey.shade100;
    }
  }

  Color get _statusTextColor {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return const Color(0xFF8D6E63); // Brownish
      case 'proses':
        return const Color(0xFF1976D2); // Blue
      case 'selesai':
        return const Color(0xFF388E3C); // Green
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(
              color: Colors.black.withOpacity(0.05), // Matches standard Owner shadow
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
          border: isToday 
              ? null // No border for active cards, use shadow
              : Border.all(color: Colors.grey.shade200), // Subtle border for non-today
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Red Accent Line ONLY for Today
              if (isToday)
                Container(
                  width: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              customerName,
                              style: AppTextStyles.heading4().copyWith(
                                fontSize: 16, 
                                fontWeight: isToday ? FontWeight.bold : FontWeight.w600
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: AppTextStyles.bodyMedium(
                                color: _statusTextColor,
                              ).copyWith(fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$vehicleName • $licensePlate',
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.build_circle_outlined,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              serviceType,
                              style: AppTextStyles.bodyMedium(
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_filled,
                                size: 16,
                                color: isToday ? AppColors.primaryRed : AppColors.textSecondary, // Accent only if today
                              ),
                              const SizedBox(width: 6),
                              Text(
                                time,
                                style: AppTextStyles.bodyMedium(
                                  color: isToday ? Colors.black87 : AppColors.textSecondary,
                                ).copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Text(
                            "Detail",
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.primaryRed,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
