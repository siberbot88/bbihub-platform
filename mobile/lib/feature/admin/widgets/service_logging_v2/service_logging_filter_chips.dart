import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ServiceLoggingFilterChips extends StatelessWidget {
  final String? selectedMake;
  final VoidCallback onDateTap;
  final VoidCallback onPriorityTap;
  final VoidCallback onMechanicTap;
  final VoidCallback? onRemoveMake;

  const ServiceLoggingFilterChips({
    super.key,
    this.selectedMake,
    required this.onDateTap,
    required this.onPriorityTap,
    required this.onMechanicTap,
    this.onRemoveMake,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'Date: Today',
            isDark: isDark,
            isSelected: false,
            hasDropdown: true,
            onTap: onDateTap,
          ),
          const SizedBox(width: 8),
          
          if (selectedMake != null)
            _FilterChip(
              label: selectedMake!,
              isDark: isDark,
              isSelected: true,
              onRemove: onRemoveMake,
            ),
          if (selectedMake != null) const SizedBox(width: 8),
          
          _FilterChip(
            label: 'Priority',
            isDark: isDark,
            isSelected: false,
            hasDropdown: true,
            onTap: onPriorityTap,
          ),
          const SizedBox(width: 8),
          
          _FilterChip(
            label: 'Mechanic',
            isDark: isDark,
            isSelected: false,
            hasDropdown: true,
            onTap: onMechanicTap,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final bool isSelected;
  final bool hasDropdown;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const _FilterChip({
    required this.label,
    required this.isDark,
    required this.isSelected,
    this.hasDropdown = false,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed : (isDark ? const Color(0xFF2F1F1E) : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryRed : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
            ),
            if (hasDropdown) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey[400],
              ),
            ],
            if (onRemove != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
