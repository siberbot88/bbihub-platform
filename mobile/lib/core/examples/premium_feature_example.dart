import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/premium_feature_lock.dart';
import '../../../core/services/auth_provider.dart';
import 'package:fl_chart/fl_chart.dart';

/// Example of how to implement Premium Feature Gating
/// 
/// This demonstrates 3 approaches:
/// 1. Wrap entire widget with PremiumFeatureLock (simplest)
/// 2. Conditional rendering based on membership status
/// 3. Partial feature limitation (show preview, lock advanced features)

class PremiumFeatureExample extends StatelessWidget {
  const PremiumFeatureExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Get user's premium status
    final auth = context.watch<AuthProvider>();
    final isPremium = auth.user?.membershipStatus == 'active';

    return Scaffold(
      appBar: AppBar(title: const Text('Premium Feature Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ============================================
          // APPROACH 1: Wrap Entire Feature with Lock
          // ============================================
          const Text(
            '1. Complete Feature Lock',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          PremiumFeatureLock(
            isLocked: !isPremium,
            featureName: 'Grafik Tren Analytics',
            featureDescription: 'Lihat tren pendapatan dengan grafik interaktif',
            child: _buildAnalyticsChart(),
          ),
          
          const SizedBox(height: 32),
          
          // ============================================
          // APPROACH 2: Conditional Rendering
          // ============================================
          const Text(
            '2. Conditional Content',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildConditionalFeature(isPremium),
          
          const SizedBox(height: 32),
          
          // ============================================
          // APPROACH 3: Partial Feature with Teaser
          // ============================================
          const Text(
            '3. Partial Feature (Preview + Lock)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildPartialFeature(isPremium),
        ],
      ),
    );
  }

  /// Approach 1: Analytics chart wrapped in PremiumFeatureLock
  Widget _buildAnalyticsChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grafik Tren',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // Show premium badge on locked features
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final isPremium = auth.user?.membershipStatus == 'active';
                  if (!isPremium) {
                    return const PremiumBadge();
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Simplified chart placeholder
          Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.analytics, size: 64, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  /// Approach 2: Show different content based on membership
  Widget _buildConditionalFeature(bool isPremium) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Staff Performance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          if (isPremium) ...[
            // Premium users see full data
            _buildStaffPerformanceItem('Ahmad', 45, 4.8),
            _buildStaffPerformanceItem('Budi', 38, 4.5),
            _buildStaffPerformanceItem('Citra', 52, 4.9),
          ] else ...[
            // Free users see limited preview + upgrade prompt
            Opacity(
              opacity: 0.5,
              child: _buildStaffPerformanceItem('Ahmad', 45, 4.8),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFA500)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    color: Color(0xFFB70F0F),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lihat Semua Staff',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Upgrade ke Premium untuk tracking lengkap',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Upgrade'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStaffPerformanceItem(String name, int jobs, double rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: Text(name[0]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '$jobs jobs selesai',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(rating.toString()),
            ],
          ),
        ],
      ),
    );
  }

  /// Approach 3: Show basic info, lock advanced features
  Widget _buildPartialFeature(bool isPremium) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Laporan Detail',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Basic stats (always visible)
          _buildBasicStat('Total Pendapatan', 'Rp 5.2jt'),
          _buildBasicStat('Total Pekerjaan', '24 order'),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Advanced features (locked for free users)
          PremiumFeatureLock(
            isLocked: !isPremium,
            featureName: 'Export PDF & Excel',
            featureDescription: 'Download laporan dalam format profesional',
            child: Column(
              children: [
                _buildExportButton('Export PDF', Icons.picture_as_pdf),
                const SizedBox(height: 8),
                _buildExportButton('Export Excel', Icons.table_chart),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        backgroundColor: const Color(0xFFB70F0F),
        foregroundColor: Colors.white,
      ),
    );
  }
}
