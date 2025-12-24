import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/feature/admin/widgets/smartasset.dart';

/// Stat card widget displaying a metric with title, value, icon, and trend
class HomeStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String assetPath;
  final String updateDate;
  final String percentage;

  const HomeStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.assetPath,
    this.updateDate = "2 days ago",
    this.percentage = "+15%",
  });

  @override
  Widget build(BuildContext context) {
    final bool isNegative = percentage.startsWith('-');
    final Color trendColor = isNegative ? Colors.red : Colors.green;

    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing based on screen width
    final double iconSize = screenWidth < 360 ? 24 : 28;
    final double fontSizeTitle = screenWidth < 360 ? 12 : 13;
    final double fontSizeValue = screenWidth < 360 ? 20 : 24;
    final double fontSizeFooter = screenWidth < 360 ? 9 : 11;
    final double iconSizeFooter = screenWidth < 360 ? 9 : 10.5;
    final double paddingVertical = screenWidth < 360 ? 8 : 10;
    final double paddingHorizontal = screenWidth < 360 ? 10 : 14;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: paddingVertical,
      ),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: fontSizeTitle,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFDC2626),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Value + Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: fontSizeValue,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFDC2626),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: SmartAsset(
                    path: assetPath,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Footer: update date + percentage trend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "Update: $updateDate",
                    style: TextStyle(
                      fontSize: fontSizeFooter,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isNegative ? Icons.arrow_downward : Icons.arrow_upward,
                      size: iconSizeFooter,
                      color: trendColor,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      percentage,
                      style: TextStyle(
                        fontSize: fontSizeFooter,
                        fontWeight: FontWeight.w500,
                        color: trendColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
