import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ServiceLoggingSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isActive;
  final ValueChanged<String> onChanged;
  final VoidCallback onCancel;
  final VoidCallback onClear;

  const ServiceLoggingSearchBar({
    super.key,
    required this.controller,
    required this.isActive,
    required this.onChanged,
    required this.onCancel,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2F1F1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? AppColors.primaryRed : Colors.transparent,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Search by Job ID, Customer...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isActive ? AppColors.primaryRed : Colors.grey[400],
                    size: 20,
                  ),
                  suffixIcon: isActive
                      ? IconButton(
                          icon: Icon(Icons.cancel, color: Colors.grey[400], size: 20),
                          onPressed: onClear,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onCancel,
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
