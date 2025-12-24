import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> with SingleTickerProviderStateMixin {
  String _selectedFilter = 'semua'; // semua | 5 | 4 | 3 | 2 | 1
  late AnimationController _animController;

  // Dummy Data
  final _reviews = <_Review>[
    _Review(
      initials: 'BS',
      name: 'Budi Santoso',
      ago: '2 jam lalu',
      stars: 5,
      service: 'Ganti Oli & Tune Up',
      text: 'Pelayanan sangat memuaskan! Mekanik ramah dan profesional. Harga juga transparan, dijelaskan detail sebelum pengerjaan. Pasti balik lagi!',
      avatarColor: Colors.blueAccent,
    ),
    _Review(
      initials: 'SN',
      name: 'Siti Nurhaliza',
      ago: '1 hari lalu',
      stars: 5,
      service: 'Service Berkala',
      text: 'Bengkel terbaik yang pernah saya kunjungi. Ruang tunggu nyaman, wifi kenceng, dan pengerjaan cepat. Recommended!',
      avatarColor: Colors.purpleAccent,
    ),
    _Review(
      initials: 'AW',
      name: 'Andi Wijaya',
      ago: '3 hari lalu',
      stars: 4,
      service: 'Perbaikan AC Mobil',
      text: 'Overall bagus, AC mobil jadi dingin lagi. Cuma agak lama nunggu karena ramai. Tapi hasil kerjanya oke.',
      avatarColor: Colors.orangeAccent,
    ),
    _Review(
      initials: 'DL',
      name: 'Dewi Lestari',
      ago: '5 hari lalu',
      stars: 5,
      service: 'Ganti Ban & Balancing',
      text: 'Cepat dan rapi! Mekaniknya juga kasih saran untuk perawatan ban. Tempatnya bersih dan nyaman.',
      avatarColor: Colors.teal,
    ),
    _Review(
      initials: 'RH',
      name: 'Rudi Hartono',
      ago: '1 minggu lalu',
      stars: 3,
      service: 'Servis Rem',
      text: 'Bagus, rem mobil jadi pakem lagi. Tapi harga agak sedikit mahal dibanding bengkel sebelah.',
      avatarColor: Colors.redAccent,
    ),
    _Review(
      initials: 'JK',
      name: 'Joko Kendil',
      ago: '2 minggu lalu',
      stars: 5,
      service: 'Cuci Mobil',
      text: 'Bersih banget! Sampai ke sela-sela mesin juga dibersihkan. Mantap jiwa!',
      avatarColor: Colors.indigo,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<_Review> get _filteredReviews {
    if (_selectedFilter == 'semua') return _reviews;
    return _reviews.where((r) => r.stars.toString() == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRatingOverview(),
                  AppSpacing.verticalSpaceXXL,
                  _buildFilterChips(),
                  AppSpacing.verticalSpaceLG,
                ],
              ),
            ),
          ),
          _buildReviewList(),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primaryRed,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(51),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        centerTitle: false,
        title: Text(
          'Ulasan Pelanggan',
          style: AppTextStyles.heading3(color: Colors.white),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  Icons.star_rounded,
                  size: 150,
                  color: Colors.white.withAlpha(25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingOverview() {
    return Container(
      padding: AppSpacing.paddingXL,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusXXL,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '4.8',
                  style: AppTextStyles.heading1(color: AppColors.textPrimary).copyWith(fontSize: 48, height: 1),
                ),
                AppSpacing.verticalSpaceXS,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return const Icon(Icons.star_rounded, color: AppColors.accentOrange, size: 20);
                  }),
                ),
                AppSpacing.verticalSpaceSM,
                Text(
                  '247 Ulasan',
                  style: AppTextStyles.bodySmall(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 80, color: AppColors.divider),
          AppSpacing.horizontalSpaceXL,
          Expanded(
            flex: 6,
            child: Column(
              children: [
                _buildProgressBar('5', 0.85),
                _buildProgressBar('4', 0.10),
                _buildProgressBar('3', 0.03),
                _buildProgressBar('2', 0.01),
                _buildProgressBar('1', 0.01),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.label(color: AppColors.textSecondary).copyWith(fontSize: 12),
          ),
          AppSpacing.horizontalSpaceSM,
          const Icon(Icons.star_rounded, size: 12, color: AppColors.accentOrange),
          AppSpacing.horizontalSpaceSM,
          Expanded(
            child: ClipRRect(
              borderRadius: AppRadius.radiusXS,
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: AppColors.backgroundLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentOrange),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['semua', '5', '4', '3', '2', '1'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (filter != 'semua') ...[
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.accentOrange,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      filter == 'semua' ? 'Semua' : filter,
                      style: isSelected
                          ? AppTextStyles.label(color: Colors.white)
                          : AppTextStyles.label(color: AppColors.textPrimary),
                    ),
                  ],
                ),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                backgroundColor: AppColors.cardBackground,
                selectedColor: AppColors.primaryRed,
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radiusXL,
                  side: BorderSide(
                    color: isSelected ? Colors.transparent : AppColors.border,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                elevation: isSelected ? 4 : 0,
                shadowColor: AppColors.primaryRed.withAlpha(100),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewList() {
    final reviews = _filteredReviews;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final review = reviews[index];
          // Staggered Animation Logic
          final animation = Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _animController,
              curve: Interval(
                (index * 0.1).clamp(0.0, 1.0),
                1.0,
                curve: Curves.easeOutQuint,
              ),
            ),
          );

          final fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: _animController,
              curve: Interval(
                (index * 0.1).clamp(0.0, 1.0),
                1.0,
                curve: Curves.easeOut,
              ),
            ),
          );

          return AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(
                  position: animation,
                  child: child,
                ),
              );
            },
            child: _buildReviewCard(review),
          );
        },
        childCount: reviews.length,
      ),
    );
  }

  Widget _buildReviewCard(_Review review) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: AppSpacing.paddingXL,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusXL,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: review.avatarColor.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.initials,
                    style: AppTextStyles.heading4(color: review.avatarColor),
                  ),
                ),
              ),
              AppSpacing.horizontalSpaceLG,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: AppTextStyles.heading5(),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          return Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: i < review.stars ? AppColors.accentOrange : AppColors.border,
                          );
                        }),
                        AppSpacing.horizontalSpaceSM,
                        Text(
                          review.ago,
                          style: AppTextStyles.caption(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceLG,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: AppRadius.radiusSM,
            ),
            child: Text(
              review.service,
              style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          AppSpacing.verticalSpaceMD,
          Text(
            review.text,
            style: AppTextStyles.bodyMedium(color: AppColors.textPrimary).copyWith(height: 1.5),
          ),
          AppSpacing.verticalSpaceLG,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.reply_rounded, size: 18),
                label: Text('Balas', style: AppTextStyles.buttonSmall(color: AppColors.primaryRed)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryRed,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXL),
                  backgroundColor: AppColors.primaryRed.withAlpha(13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Review {
  final String initials;
  final String name;
  final String ago;
  final int stars;
  final String service;
  final String text;
  final Color avatarColor;

  const _Review({
    required this.initials,
    required this.name,
    required this.ago,
    required this.stars,
    required this.service,
    required this.text,
    required this.avatarColor,
  });
}
