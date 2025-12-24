import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/core/models/staff_performance.dart';
import 'package:bengkel_online_flutter/core/theme/app_colors.dart';
import 'package:bengkel_online_flutter/core/theme/app_text_styles.dart';
import 'package:bengkel_online_flutter/core/theme/app_radius.dart';
import 'package:bengkel_online_flutter/core/theme/app_spacing.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/dashboard/dashboard_helpers.dart';

/// Performance card widget untuk menampilkan metrics per staff
class PerformanceCard extends StatelessWidget {
  final StaffPerformance performance;
  final VoidCallback? onTap;

  const PerformanceCard({
    super.key,
    required this.performance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLG,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusLG,
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar + Name + Role
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryRed.withValues(alpha: 0.1),
                    backgroundImage: performance.avatarUrl.isNotEmpty
                        ? NetworkImage(performance.avatarUrl)
                        : null,
                    child: performance.avatarUrl.isEmpty
                        ? const Icon(Icons.person, color: AppColors.primaryRed)
                        : null,
                  ),
                  AppSpacing.horizontalSpaceMD,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          performance.name,
                          style: AppTextStyles.heading5(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.verticalSpaceXS,
                        Text(
                          performance.roleDisplayName,
                          style: AppTextStyles.bodySmall(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              
              AppSpacing.verticalSpaceLG,
              
              // Metrics Grid
              Row(
                children: [
                  Expanded(
                    child: _MetricBox(
                      label: 'Jobs Selesai',
                      value: performance.jobsDone.toString(),
                      icon: Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                  ),
                  AppSpacing.horizontalSpaceSM,
                  Expanded(
                    child: _MetricBox(
                      label: 'Sedang Dikerjakan',
                      value: performance.jobsInProgress.toString(),
                      icon: Icons.build_circle_outlined,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              
              AppSpacing.verticalSpaceMD,
              
              // Revenue
              Container(
                padding: AppSpacing.paddingSM,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.05),
                  borderRadius: AppRadius.radiusMD,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      color: AppColors.primaryRed,
                      size: 20,
                    ),
                    AppSpacing.horizontalSpaceXS,
                    Text(
                      'Pendapatan: ',
                      style: AppTextStyles.bodySmall(),
                    ),
                    Text(
                      'Rp ${rupiah(performance.estimatedRevenue)}',
                      style: AppTextStyles.labelBold(
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Metric box untuk individual metric
class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingSM,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          AppSpacing.verticalSpaceXS,
          Text(
            value,
            style: AppTextStyles.heading4(color: color),
          ),
          Text(
            label,
            style: AppTextStyles.caption(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
