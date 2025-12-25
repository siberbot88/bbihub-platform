import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/models/user.dart';
import '../../../core/services/auth_provider.dart';
import '../../../core/services/api_service.dart';

class UnderlineCurvePainter extends CustomPainter {
  final Color color;

  UnderlineCurvePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width,
      size.height * 0.5,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Premium Membership Screen dengan UI yang mendekati pixel perfect
class PremiumMembershipScreen extends StatefulWidget {
  const PremiumMembershipScreen({
    super.key,
    this.onViewMembershipPackages,
    this.onContinueFreeVersion,
    this.isViewOnly = false,
  });

  final VoidCallback? onViewMembershipPackages;
  final VoidCallback? onContinueFreeVersion;
  final bool isViewOnly;

  @override
  State<PremiumMembershipScreen> createState() => _PremiumMembershipScreenState();
}

class _PremiumMembershipScreenState extends State<PremiumMembershipScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  final ScrollController _scrollController = ScrollController();
  // ignore: unused_field
  bool _isPressed = false; // Used for animation state tracking

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Slower for "lazy" feel
      reverseDuration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutQuart, // Smooth lazy curve
        reverseCurve: Curves.easeInQuart,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _scrollController.dispose(); // Added
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar styling based on theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : AppColors.backgroundWhite;
    final primaryColor = AppColors.primaryRed; 
    
    // Check Subscription Status
    final auth = context.watch<AuthProvider>();
    final isPremium = auth.user?.isPremium ?? false;

    // IF PREMIUM: Show Active Subscription View
    if (isPremium && !widget.isViewOnly) {
       return Scaffold(
         backgroundColor: backgroundColor,
         appBar: AppBar(
           backgroundColor: backgroundColor,
           elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
           title: Text('Langganan Saya', style: AppTextStyles.heading4(color: isDark ? Colors.white : Colors.black)),
           centerTitle: true,
         ),
         body: _buildActiveSubscriptionView(context, auth.user!),
       );
    }

    // IF NOT PREMIUM or ViewOnly: Show Upgrade UI
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshStatus,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!widget.isViewOnly) ...[
                        // Header nav
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                                splashRadius: 24,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'PRO',
                                  style: AppTextStyles.labelBold(color: primaryColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Hero Image - Fixed Height
                      Container(
                        height: 250,
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 10, bottom: 20),
                        child: Image.asset(
                          'assets/image/premium_hero.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(Icons.workspace_premium, size: 80, color: Colors.amber[300]),
                            );
                          },
                        ),
                      ),

                      // Title Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Text(
                              'Upgrade ke Premium',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.heading2(
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ).copyWith(height: 1.2),
                            ),
                            const SizedBox(height: 8),
                            Stack(
                              children: [
                                Positioned(
                                  bottom: -2,
                                  left: 0,
                                  right: 0,
                                  child: CustomPaint(
                                    painter: UnderlineCurvePainter(
                                      color: primaryColor.withAlpha(40), 
                                    ),
                                    size: const Size(double.infinity, 12),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Text(
                                    'Untung Lebih Banyak!',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.heading2(
                                      color: primaryColor,
                                    ).copyWith(height: 1.2),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      AppSpacing.verticalSpaceMD,

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Nikmati fitur eksklusif untuk memaksimalkan\npertumbuhan bengkel Anda.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium(
                            color: isDark ? Colors.grey[300] : AppColors.textSecondary,
                          ).copyWith(height: 1.5),
                        ),
                      ),

                      AppSpacing.verticalSpaceXL,

                      // Benefits List
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildBenefitRow(
                              context,
                              icon: Icons.analytics_outlined,
                              title: 'Analisis Bisnis Mendalam',
                              subtitle: 'Pantau performa bengkel dengan grafik detail.',
                              isLast: false,
                            ),
                            _buildBenefitRow(
                              context,
                              icon: Icons.people_outline_rounded,
                              title: 'Manajemen Staff Tanpa Batas',
                              subtitle: 'Kelola tim dan jadwal kerja lebih efisien.',
                              isLast: false,
                            ),
                            _buildBenefitRow(
                              context,
                              icon: Icons.print_outlined,
                              title: 'Cetak Laporan Otomatis',
                              subtitle: 'Export laporan keuangan dalam sekali klik.',
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            
            // Bottom Buttons (Fixed at bottom)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                
              ),
              child: Column(
                children: [
                   // CTA Button with Scale Animation
                  GestureDetector(
                    onTapDown: (_) {
                      setState(() => _isPressed = true);
                      _scaleController.forward();
                    },
                    onTapUp: (_) {
                      setState(() => _isPressed = false);
                      _scaleController.reverse();
                      widget.onViewMembershipPackages?.call();
                    },
                    onTapCancel: () {
                      setState(() => _isPressed = false);
                      _scaleController.reverse();
                    },
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: AppRadius.radiusXL,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withAlpha(80),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Lihat Paket Membership',
                                style: AppTextStyles.button(), 
                              ),
                              AppSpacing.horizontalSpaceSM,
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  AppSpacing.verticalSpaceSM,
                  
                  // Secondary Button
                  TextButton(
                    onPressed: () {
                      if (widget.onContinueFreeVersion != null) {
                        widget.onContinueFreeVersion!();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      splashFactory: InkRipple.splashFactory,
                    ),
                    child: Text(
                      'Lanjut pakai versi gratis',
                      style: AppTextStyles.labelBold(
                        color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSubscriptionView(BuildContext context, User user) {
     final primaryColor = AppColors.primaryRed;
     final isDark = Theme.of(context).brightness == Brightness.dark;
     final isTrial = user.isInTrial;

     // Format Date
     String formattedDate = '30 Hari'; // Default fallback
     String statusLabel = 'AKTIF';
     Color statusColor = Colors.green;
     String planName = user.subscriptionPlanName ?? 'Premium Plan';
     String benefitTitle = 'Keuntungan Paket Anda:';

     if (isTrial) {
        planName = 'Trial Premium';
        statusLabel = 'TRIAL';
        statusColor = Colors.blue;
        benefitTitle = 'Fitur Trial Anda:';
        
        if (user.trialEndsAt != null) {
          final daysLeft = user.trialDaysRemaining ?? user.trialEndsAt!.difference(DateTime.now()).inDays;
          formattedDate = "$daysLeft Hari Lagi";
        }
     } else if (user.subscriptionExpiredAt != null) {
        final date = user.subscriptionExpiredAt!;
        formattedDate = "${date.day}/${date.month}/${date.year}";
     } else {
        formattedDate = "Aktif Selamanya"; 
     }

     return RefreshIndicator(
       onRefresh: _refreshStatus,
       child: SingleChildScrollView(
         physics: const AlwaysScrollableScrollPhysics(),
         child: Padding(
           padding: const EdgeInsets.all(20.0),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.stretch,
             children: [
               Container(
                 padding: const EdgeInsets.all(24),
                 decoration: BoxDecoration(
                   gradient: LinearGradient(
                     colors: [
                       isDark ? const Color(0xFF2C2C2C) : Colors.white,
                       isDark ? const Color(0xFF222222) : const Color(0xFFF8F9FA),
                     ],
                     begin: Alignment.topLeft,
                     end: Alignment.bottomRight
                   ),
                   borderRadius: BorderRadius.circular(24),
                   boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))
                   ],
                   border: Border.all(color: isTrial ? Colors.blue.withValues(alpha: 0.5) : Colors.amber.withValues(alpha: 0.5), width: 1)
                 ),
                 child: Column(
                   children: [
                     Icon(
                        isTrial ? Icons.timer_outlined : Icons.verified, 
                        color: isTrial ? Colors.blue : Colors.amber, 
                        size: 48
                     ),
                     const SizedBox(height: 16),
                     Text(
                       isTrial ? 'Status Membership' : 'Paket Aktif',
                      style: AppTextStyles.labelBold(color: Colors.grey),
                     ),
                     const SizedBox(height: 8),
                     Text(
                       planName,
                       style: AppTextStyles.heading2(color: isDark ? Colors.white : Colors.black87),
                       textAlign: TextAlign.center,
                     ),
                     const SizedBox(height: 24),
                     Divider(color: Colors.grey.withValues(alpha: 0.2)),
                     const SizedBox(height: 24),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text(isTrial ? 'Sisa Waktu' : 'Masa Berlaku', style: AppTextStyles.bodyMedium(color: Colors.grey)),
                         Text(formattedDate, style: AppTextStyles.heading5(color: isDark ? Colors.white : Colors.black87)),
                       ],
                     ),
                      const SizedBox(height: 12),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text('Status', style: AppTextStyles.bodyMedium(color: Colors.grey)),
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                           decoration: BoxDecoration(
                             color: statusColor.withValues(alpha: 0.1),
                             borderRadius: BorderRadius.circular(20)
                           ),
                           child: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                         )
                       ],
                     )
                   ],
                 ),
               ),
               
               const SizedBox(height: 32),
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 8),
                 child: Text(
                   benefitTitle,
                    style: AppTextStyles.heading4(color: isDark ? Colors.white : Colors.black87),
                 ),
               ),
                const SizedBox(height: 16),
                 _buildBenefitRow(
                   context,
                   icon: Icons.analytics_outlined,
                   title: 'Analisis Bisnis Mendalam',
                   subtitle: 'Akses penuh ke semua grafik performa bengkel.',
                   isLast: false,
                 ),
                 _buildBenefitRow(
                   context,
                   icon: Icons.people_outline_rounded,
                   title: 'Manajemen Staff Tanpa Batas',
                   subtitle: 'Tidak ada batasan jumlah karyawan.',
                   isLast: false,
                 ),
                 _buildBenefitRow(
                   context,
                   icon: Icons.print_outlined,
                   title: 'Laporan Keuangan Prioritas',
                   subtitle: 'Export data kapan saja tanpa batasan.',
                   isLast: true,
                 ),
   
               const SizedBox(height: 40),
               
               if (isTrial) ...[
                  Text(
                    "Trial akan otomatis berakhir.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => _showCancelSubscriptionDialog(context, isTrial: true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text(
                        'Batalkan Trial',
                        style: AppTextStyles.labelBold(color: Colors.red),
                      ),
                    ),
                  ),
               ] else ...[
                  Text(
                    "Ingin mengubah paket?",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: widget.onViewMembershipPackages,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                    ),
                    child: Text('Perpanjang / Ganti Paket', style: AppTextStyles.button(color: Colors.white)),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => _showCancelSubscriptionDialog(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text(
                        'Batalkan Langganan',
                        style: AppTextStyles.labelBold(color: Colors.red),
                      ),
                    ),
                  ),
               ],

                const SizedBox(height: 32),
             ],
           ),
         ),
       ),
     );
  }

  Widget _buildBenefitRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isLast,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primaryRed;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Container(
        padding: AppSpacing.paddingMD,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: AppRadius.radiusLG,
          border: Border.all(
            color: isDark ? Colors.transparent : Colors.grey.withAlpha(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10), // Softer shadow
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(isDark ? 30 : 15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: 20,
              ),
            ),
            AppSpacing.horizontalSpaceMD,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.heading5(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall(
                      color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                    ).copyWith(height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }


  Future<void> _refreshStatus() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final authProvider = context.read<AuthProvider>();
    
    try {
      final api = ApiService();
      await api.checkSubscriptionStatus();
      if (!mounted) return;
      await authProvider.checkLoginStatus();
      if (!mounted) return;
      
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Status langganan diperbarui'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  void _showCancelSubscriptionDialog(BuildContext context, {bool isTrial = false}) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                isTrial ? 'Batalkan Trial?' : 'Batalkan Langganan?',
                style: AppTextStyles.heading3(color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isTrial 
                    ? 'Anda akan segera kehilangan akses ke fitur Premium. Apakah Anda yakin?'
                    : 'Anda akan kehilangan akses ke fitur Premium setelah periode langganan saat ini berakhir. Apakah Anda yakin?',
                style: AppTextStyles.bodyMedium(color: Colors.grey[600]!),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx); // Close dialog
                    
                    // Show loading
                    showDialog(
                      context: context, 
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator())
                    );
                    
                    final navigator = Navigator.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final authProvider = context.read<AuthProvider>();
                    
                    try {
                      final api = ApiService();
                      await api.cancelSubscription();
                      
                      if (!mounted) return;
                      navigator.pop(); // Close loading
                      
                      // Refresh user data
                      await authProvider.checkLoginStatus();
                      
                      if (!mounted) return;
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(content: Text('Langganan berhasil dibatalkan'), backgroundColor: Colors.green),
                      );
                      navigator.pop(); // Close Premium Screen
                      
                    } catch (e) {
                      if (!mounted) return;
                      navigator.pop(); // Close loading
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: Text('Ya, Batalkan', style: AppTextStyles.button(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Tidak, Kembali', style: AppTextStyles.bodyMedium(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
