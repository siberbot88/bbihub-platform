import 'package:flutter/material.dart';

class ReportHealthTile extends StatelessWidget {
  const ReportHealthTile({
    super.key,
    required this.title,
    required this.value,
    required this.tag,
    required this.tagColor,
  });

  final String title;
  final String value;
  final String tag;
  final Color tagColor;

  IconData _getIconFromTitle(String title) {
    if (title.toLowerCase().contains('antrian')) {
      return Icons.queue_rounded;
    } else if (title.toLowerCase().contains('occupancy')) {
      return Icons.engineering_rounded;
    } else if (title.toLowerCase().contains('peak')) {
      return Icons.schedule_rounded;
    } else if (title.toLowerCase().contains('efisiensi')) {
      return Icons.speed_rounded;
    }
    return Icons.analytics_rounded;
  }

  double _getProgressFromValue(String value) {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(value);
    if (match != null) {
      final number = int.tryParse(match.group(1) ?? '0') ?? 0;
      if (value.contains('%')) {
        return number / 100;
      } else {
        return (number / 10).clamp(0.0, 1.0);
      }
    }
    return 0.5;
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIconFromTitle(title);
    final progress = _getProgressFromValue(value);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon and badge
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF999999),
                size: 16,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: tagColor.withAlpha(40),
                    width: 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: tagColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Title
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          
          // Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
              height: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          
          // Subtle progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF5F5F5),
              valueColor: AlwaysStoppedAnimation<Color>(tagColor.withAlpha(180)),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}
