import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/repositories/feedback_repository.dart';
import '../../../../core/models/feedback_model.dart';
import '../widgets/custom_header.dart'; // Ensure correct import

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final FeedbackRepository _repository = FeedbackRepository();
  final ScrollController _scrollController = ScrollController();

  // State
  bool _isLoading = true;
  bool _isLoadingMore = false;
  
  // Data
  FeedbackSummary? _summary;
  List<FeedbackItem> _reviews = [];
  int _currentPage = 1;
  int _lastPage = 1;
  String _selectedFilter = 'semua'; // semua | 5 | 4 | 3 | 2 | 1

  @override
  void initState() {
    super.initState();
    _fetchFeedback();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _currentPage < _lastPage) {
        _loadMore();
      }
    }
  }

  Future<void> _fetchFeedback({bool refresh = false}) async {
    if (!refresh) {
      setState(() => _isLoading = true);
    }
    
    try {
      final response = await _repository.getFeedback(page: 1, filter: _selectedFilter);
      if (mounted) {
        setState(() {
          _summary = response.summary;
          _reviews = response.reviews;
          _currentPage = response.meta.currentPage;
          _lastPage = response.meta.lastPage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    try {
      final nextPage = _currentPage + 1;
      final response = await _repository.getFeedback(page: nextPage, filter: _selectedFilter);
      if (mounted) {
        setState(() {
          _reviews.addAll(response.reviews);
          _currentPage = response.meta.currentPage;
          _lastPage = response.meta.lastPage;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _onFilterChanged(String filter) {
    if (_selectedFilter == filter) return;
    setState(() {
      _selectedFilter = filter;
      _reviews.clear();
      _summary = null; 
    });
    _fetchFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomHeader(
        title: "Ulasan Pelanggan",
        onBack: () => Navigator.pop(context),
      ),
      body: _isLoading && _reviews.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _fetchFeedback(refresh: true),
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSpacing.verticalSpaceLG,
                      
                      // Show Summary if loaded
                      if (_summary != null) ...[
                        _buildRatingOverview(_summary!),
                        AppSpacing.verticalSpaceXXL,
                      ],
                      
                      _buildFilterChips(),
                      AppSpacing.verticalSpaceLG,
                      
                      if (_reviews.isEmpty)
                         _buildEmptyState(),
                      
                      if (_reviews.isNotEmpty)
                        _buildReviewList(),
                        
                      if (_isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        
                      AppSpacing.verticalSpaceXXL,
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.rate_review_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Belum ada ulasan",
            style: AppTextStyles.heading4(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'semua' 
                ? "Pelanggan belum memberikan ulasan."
                : "Tidak ada ulasan dengan rating $_selectedFilter bintang.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingOverview(FeedbackSummary d) {
    return Container(
      padding: AppSpacing.paddingXL,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXL,
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  d.average.toStringAsFixed(1),
                  style: AppTextStyles.heading1(color: AppColors.textPrimary).copyWith(
                    fontSize: 52,
                    height: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.verticalSpaceXS,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                     // Handle partial stars visually if needed, simpler for now
                     bool isActive = index < d.average.round();
                    return Icon(
                      Icons.star_rounded,
                      color: isActive ? AppColors.accentOrange : Colors.grey[300],
                      size: 22,
                    );
                  }),
                ),
                AppSpacing.verticalSpaceSM,
                Text(
                  '${d.total} Ulasan',
                  style: AppTextStyles.bodySmall(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 90, color: AppColors.divider),
          AppSpacing.horizontalSpaceXL,
          Expanded(
            flex: 6,
            child: Column(
              children: [
                _buildProgressBar('5', d.distribution['5'] ?? 0),
                _buildProgressBar('4', d.distribution['4'] ?? 0),
                _buildProgressBar('3', d.distribution['3'] ?? 0),
                _buildProgressBar('2', d.distribution['2'] ?? 0),
                _buildProgressBar('1', d.distribution['1'] ?? 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall(color: AppColors.textSecondary).copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          AppSpacing.horizontalSpaceSM,
          const Icon(Icons.star_rounded, size: 14, color: AppColors.accentOrange),
          AppSpacing.horizontalSpaceSM,
          Expanded(
            child: ClipRRect(
              borderRadius: AppRadius.radiusSM,
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: AppColors.backgroundLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentOrange),
                minHeight: 7,
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
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                if(selected) _onFilterChanged(filter);
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusXL,
                side: BorderSide(
                  color: isSelected ? Colors.transparent : AppColors.border,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: isSelected ? 2 : 0,
              shadowColor: AppColors.primaryRed.withAlpha(76),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewList() {
    return Column(
      children: _reviews.map((review) => _buildReviewCard(review)).toList(),
    );
  }

  Widget _buildReviewCard(FeedbackItem review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      // ... (rest of styling same as before)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.border.withAlpha(128), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote Icon
          Icon(
            Icons.format_quote_rounded,
            size: 32,
            color: AppColors.accentOrange.withAlpha(76),
          ),
          AppSpacing.verticalSpaceSM,
          
          // Review Text
          Text(
            review.comment.isEmpty ? "Tidak ada komentar." : review.comment,
            style: AppTextStyles.bodyMedium(color: AppColors.textPrimary).copyWith(
              height: 1.6,
              fontSize: 14,
              fontStyle: review.comment.isEmpty ? FontStyle.italic : FontStyle.normal,
              color: review.comment.isEmpty ? Colors.grey : AppColors.textPrimary,
            ),
          ),
          
          AppSpacing.verticalSpaceLG,
          
          // User Info
          Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: review.avatarColor.withAlpha(38),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.initials,
                    style: AppTextStyles.heading5(color: review.avatarColor).copyWith(
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              AppSpacing.horizontalSpaceMD,
              
              // Name, Stars, Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.customerName,
                      style: AppTextStyles.heading5(color: AppColors.textPrimary).copyWith(
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          return Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: i < review.rating
                                ? AppColors.accentOrange
                                : AppColors.border,
                          );
                        }),
                        AppSpacing.horizontalSpaceSM,
                        Text(
                          review.timeAgo,
                          style: AppTextStyles.caption(color: AppColors.textHint).copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    // Show Service Name
                    Text(
                      review.serviceName,
                       style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
