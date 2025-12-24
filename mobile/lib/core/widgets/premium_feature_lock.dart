import 'dart:ui';
import 'package:flutter/material.dart';

/// Premium feature lock overlay widget
/// Shows blurred content with upgrade prompt for free users
class PremiumFeatureLock extends StatelessWidget {
  final Widget child;
  final String featureName;
  final String featureDescription;
  final VoidCallback? onUpgrade;
  final bool isLocked;
  
  const PremiumFeatureLock({
    super.key,
    required this.child,
    required this.featureName,
    required this.featureDescription,
    this.onUpgrade,
    this.isLocked = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLocked) {
      return child; // Premium user - show content normally
    }

    return Stack(
      children: [
        // Blurred content
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Opacity(
              opacity: 0.4,
              child: child,
            ),
          ),
        ),
        
        // Lock overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Crown/Lock icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      size: 48,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Feature name
                  Text(
                    featureName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      featureDescription,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Upgrade button
                  ElevatedButton.icon(
                    onPressed: onUpgrade ?? () => _showUpgradeBottomSheet(context),
                    icon: const Icon(Icons.arrow_upward, size: 18),
                    label: const Text('Upgrade ke Premium'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB70F0F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showUpgradeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PremiumUpgradeBottomSheet(),
    );
  }
}

/// Premium upgrade bottom sheet with benefits
class PremiumUpgradeBottomSheet extends StatelessWidget {
  const PremiumUpgradeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          const Text(
            'Upgrade ke Premium',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Untung Lebih Banyak!',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFB70F0F),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nikmati fitur eksklusif untuk memaksimalkan pertumbuhan bengkel Anda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Benefits
          _buildBenefit(
            icon: Icons.analytics,
            color: const Color(0xFF7C3AED),
            title: 'Analisis Bisnis Mendalam',
            subtitle: 'Pantau performa bengkel dengan grafis detail',
          ),
          const SizedBox(height: 16),
          _buildBenefit(
            icon: Icons.people,
            color: const Color(0xFFEF4444),
            title: 'Manajemen Staff Tanpa Batas',
            subtitle: 'Kelola tim dan pantau kerja lebih efisien',
          ),
          const SizedBox(height: 16),
          _buildBenefit(
            icon: Icons.print,
            color: const Color(0xFFB70F0F),
            title: 'Cetak Laporan Otomatis',
            subtitle: 'Export laporan PDF dengan sekali klik',
          ),
          const SizedBox(height: 24),
          
          // Pricing
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFD700),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_offer,
                  color: Color(0xFFB70F0F),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hanya Rp 99.000/bulan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB70F0F),
                        ),
                      ),
                      Text(
                        'Hemat 20% untuk paket tahunan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // CTA Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to membership screen
                Navigator.pushNamed(context, '/premium-membership');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB70F0F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Mulai Berlangganan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Cancel button
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Nanti Saja',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildBenefit({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Premium badge widget for UI elements
class PremiumBadge extends StatelessWidget {
  final String? text;
  
  const PremiumBadge({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.workspace_premium,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            text ?? 'PREMIUM',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
