import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../data/models/membership_plan_model.dart';
import 'payment_screen.dart';

class MembershipSelectionScreen extends StatefulWidget {
  const MembershipSelectionScreen({super.key});

  @override
  State<MembershipSelectionScreen> createState() => _MembershipSelectionScreenState();
}

class _MembershipSelectionScreenState extends State<MembershipSelectionScreen> {
  BillingCycle _selectedCycle = BillingCycle.yearly; // Default Yearly
  MembershipPlanModel? _selectedPlan;
  
  // Hardcoded Data for UI
  final MembershipPlanModel _starterPlan = const MembershipPlanModel(
    id: "starter",
    name: "Starter",
    description: "Fitur dasar untuk bengkel kecil.",
    tier: MembershipTier.free,
    monthlyPrice: 0,
    yearlyPrice: 0,
    featuresIncluded: [
      "Manajemen Bengkel Dasar",
      "1 Admin",
      "Maksimal 5 Mekanik",
    ],
    featuresExcluded: [
      "Analitik Canggih",
      "Unlimited Mekanik & Admin",
    ],
  );

  final MembershipPlanModel _plusPlan = const MembershipPlanModel(
    id: "bbi_hub_plus",
    name: "BBI HUB Plus",
    description: "Kembangkan bisnis lebih cepat.",
    tier: MembershipTier.premium,
    monthlyPrice: 120000, 
    yearlyPrice: 1440000, 
    isRecommended: true,
    featuresIncluded: [
      "Semua fitur Starter",
      "Dashboard Analitik Canggih",
      "Unlimited Mekanik & Admin",
      "Laporan Keuangan Detail",
    ],
  );

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        centerTitle: true,
        title: Text('Pilih Paket', style: AppTextStyles.heading4(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppSpacing.verticalSpaceMD,
                  Text(
                    'Buka Potensi Penuh',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading3(color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih paket yang sesuai dengan kebutuhan\nbengkel Anda dan mulai berkembang.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium(color: Colors.grey[600]),
                  ),
                  AppSpacing.verticalSpaceLG,

                  // Toggle Switch
                  _buildBillingToggle(),

                  AppSpacing.verticalSpaceXL,

                  // Starter Plan
                  _buildPlanCard(
                    plan: _starterPlan,
                    isSelected: _selectedPlan?.id == _starterPlan.id,
                  ),

                  AppSpacing.verticalSpaceLG,

                  // Premium Plan
                  _buildPlanCard(
                    plan: _plusPlan,
                    isSelected: _selectedPlan?.id == _plusPlan.id,
                  ),
                  
                  AppSpacing.verticalSpaceLG,

                  // Security Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Pembayaran aman dengan Enkripsi SSL. Anda dapat membatalkan kapan saja.',
                          style: AppTextStyles.caption(color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalSpaceXL,
                ],
              ),
            ),
          ),
          
          // Fixed Bottom Summary
          _buildBottomSummary(currencyFormat),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption('Bulanan', BillingCycle.monthly),
          _buildToggleOption('Tahunan', BillingCycle.yearly, hasBadge: true),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String text, BillingCycle cycle, {bool hasBadge = false}) {
    final isSelected = _selectedCycle == cycle;
    return GestureDetector(
      onTap: () => setState(() => _selectedCycle = cycle),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Text(
              text,
              style: AppTextStyles.labelBold(
                color: isSelected ? Colors.black : Colors.grey[600],
              ),
            ),
            if (hasBadge)
              Positioned(
                top: -14,
                right: -20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5), // Light green
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Text(
                    'HEMAT',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary(NumberFormat currency) {
    int total = 0;
    if (_selectedPlan != null) {
      if (_selectedPlan!.tier == MembershipTier.free) {
        total = 0;
      } else {
        // If yearly, use total yearly price, else monthly
        // Note: The prompt says "Ditagih tahunan (Rp 1.440.000)" implies the total charge is that.
        total = (_selectedCycle == BillingCycle.yearly) 
            ? _selectedPlan!.yearlyPrice 
            : _selectedPlan!.monthlyPrice;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total bayar', style: AppTextStyles.bodyMedium(color: Colors.grey[600])),
              Text(
                currency.format(total),
                style: AppTextStyles.heading4(color: Colors.black),
              ),
            ],
          ),
          AppSpacing.verticalSpaceMD,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedPlan == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                            plan: _selectedPlan!,
                            billingCycle: _selectedCycle,
                            totalAmount: total,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.buttonRadius,
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lanjut ke pembayaran',
                    style: AppTextStyles.button(color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required MembershipPlanModel plan,
    required bool isSelected,
  }) {
    final isPremium = plan.tier == MembershipTier.premium;
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected && isPremium
                    ? AppColors.primaryRed
                    : (isSelected ? Colors.black : Colors.grey[200]!),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isPremium && isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryRed.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPremium) ...[
                  Text(plan.name, style: AppTextStyles.heading4(color: AppColors.primaryRed)),
                ] else ...[
                  Text(plan.name, style: AppTextStyles.heading4()),
                ],
                const SizedBox(height: 4),
                Text(
                  plan.description,
                  style: AppTextStyles.bodySmall(color: Colors.grey[600]),
                ),
                AppSpacing.verticalSpaceMD,
                
                // Pricing
                if (plan.tier == MembershipTier.free) ...[
                  Text('Gratis', style: AppTextStyles.heading2()),
                  Text('Gratis selamanya', style: AppTextStyles.caption(color: Colors.grey[500])),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp ${currency.format(plan.monthlyPrice)}',
                        style: AppTextStyles.heading2(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          ' / bln',
                          style: AppTextStyles.bodyMedium(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                   // Specific logic based on design requirement:
                   // "Rp 120.000 / bln" shown always for premium? 
                   // If cycle is Yearly, show "Ditagih tahunan (Rp 1.440.000)"
                   if (_selectedCycle == BillingCycle.yearly) 
                     Text(
                        'Ditagih tahunan (Rp ${currency.format(plan.yearlyPrice)})',
                        style: AppTextStyles.caption(color: Colors.green[700]).copyWith(fontWeight: FontWeight.bold),
                      )
                   else
                     Text(
                        'Ditagih bulanan (Rp ${currency.format(plan.monthlyPrice)})',
                        style: AppTextStyles.caption(color: Colors.grey[500]),
                      ),
                ],

                const Divider(height: 32),

                // Features
                ...plan.featuresIncluded.map((f) => _buildFeatureItem(f, true)),
                ...plan.featuresExcluded.map((f) => _buildFeatureItem(f, false)),

                AppSpacing.verticalSpaceLG,

                // Selection Button
                SizedBox(
                  width: double.infinity,
                  child: isSelected && isPremium
                      ? ElevatedButton.icon(
                          onPressed: () {}, // Already selected
                          icon: const Icon(Icons.check_circle, color: Colors.white, size: 20),
                          label: Text('Paket Dipilih', style: AppTextStyles.button(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        )
                      : OutlinedButton(
                          onPressed: () => setState(() => _selectedPlan = plan),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isSelected ? Colors.black : Colors.grey[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            isSelected ? 'Paket Dipilih' : 'Pilih paket ini',
                            style: AppTextStyles.button(
                              color: isSelected ? Colors.black : Colors.grey[700],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          if (plan.isRecommended)
            Positioned(
              top: -12,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryRed.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'REKOMENDASI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, bool isIncluded) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isIncluded ? Icons.check : Icons.close,
            color: isIncluded ? (isIncluded && text.contains("Starter") ? Colors.red[300] : Colors.grey[800]) : Colors.grey[400], // Slightly distinct icon colors if needed
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall(
                color: isIncluded ? Colors.black87 : Colors.grey[400],
              ).copyWith(
                decoration: isIncluded ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
