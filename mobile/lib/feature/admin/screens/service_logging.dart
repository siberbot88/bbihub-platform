import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../../../../core/services/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/service.dart';
import '../providers/admin_service_provider.dart';
import 'service_detail_page.dart';
import '../widgets/service_logging_v2/service_logging_search_bar.dart';
import '../widgets/service_logging_v2/service_logging_summary_cards.dart';
import '../widgets/service_logging_v2/service_logging_filter_chips.dart';
import '../widgets/service_logging_v2/service_logging_card.dart';
import '../widgets/service_logging_v2/date_range_picker_sheet.dart';

class ServiceLoggingPage extends StatefulWidget {
  const ServiceLoggingPage({super.key});

  @override
  State<ServiceLoggingPage> createState() => _ServiceLoggingPageState();
}

class _ServiceLoggingPageState extends State<ServiceLoggingPage> with SingleTickerProviderStateMixin {
  // State
  List<ServiceModel> _services = [];
  bool _isLoading = true;
  
  // Search
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  Timer? _debounce;
  
  // Filters
  String _selectedStatus = 'Semua';
  final List<String> _statusFilters = ['Semua', 'Menunggu', 'Proses', 'Dibatalkan'];
  
  String? _selectedMake;
  
  // Date filter variables
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    // _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final workshopUuid = auth.user?.workshopUuid;
      
      String? statusParam;
      if (_selectedStatus == 'Semua') statusParam = 'pending,in_progress,in progress,on_process,accepted,menunggu pembayaran,waiting_payment,cancelled,cancel,decline';
      if (_selectedStatus == 'Menunggu') statusParam = 'pending';
      if (_selectedStatus == 'Proses') statusParam = 'in_progress,in progress,on_process,accepted,menunggu pembayaran,waiting_payment'; 
      if (_selectedStatus == 'Dibatalkan') statusParam = 'cancelled,cancel,decline';
      
      // Use fetchServices instead of fetchActiveServices to support all statuses
      await context.read<AdminServiceProvider>().fetchServices(
        workshopUuid: workshopUuid,
        status: statusParam,
        dateFrom: _dateFrom != null ? DateFormat('yyyy-MM-dd').format(_dateFrom!) : null,
        dateTo: _dateTo != null ? DateFormat('yyyy-MM-dd').format(_dateTo!) : null,
        search: _searchController.text,
        acceptanceStatus: 'accepted',
        useScheduleEndpoint: false, // Use flat list for logging
      );

      if (mounted) {
        setState(() {
          // Items are in provider
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _fetchData();
    });
  }

  List<ServiceModel> get _filteredServices {
    final provider = context.read<AdminServiceProvider>();
    return provider.items; // Filtering is done API side or provider side
  }

  int get _activeCount => _filteredServices.where((s) => 
    ['in_progress', 'in progress'].contains(s.status.toLowerCase())
  ).length;
  
  int get _delayedCount => 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF211211) : const Color(0xFFF8F6F6),
      body: SafeArea(
        child: Column(
          children: [
            ServiceLoggingSearchBar(
              controller: _searchController,
              isActive: _isSearchActive,
              onChanged: (value) {
                setState(() => _isSearchActive = value.isNotEmpty);
                _onSearchChanged(value);
              },
              onClear: () {
                _searchController.clear();
                setState(() => _isSearchActive = false);
                _fetchData();
              },
              onCancel: () {
                _searchController.clear();
                setState(() => _isSearchActive = false);
                FocusScope.of(context).unfocus();
                _fetchData();
              },
            ),
            
            _buildFilterTabs(),
            
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ServiceLoggingSummaryCards(
                        activeCount: _activeCount,
                        delayedCount: _delayedCount,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      ServiceLoggingFilterChips(
                        selectedMake: _selectedMake,
                        onDateTap: () => _showDateRangePicker(),
                        onPriorityTap: () {},
                        onMechanicTap: () {},
                        onRemoveMake: () {
                          setState(() => _selectedMake = null);
                          _fetchData();
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        'TOP MATCHES',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.grey[600] : Colors.grey[500],
                          letterSpacing: 1.2,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_filteredServices.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('No services found'),
                          ),
                        )
                      else
                        ..._filteredServices.map((service) => ServiceLoggingCard(
                          service: service,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ServiceDetailPage(service: service),
                              ),
                            );
                          },
                        )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _statusFilters.map((filter) {
          final isSelected = _selectedStatus == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                if (_selectedStatus != filter) {
                  setState(() => _selectedStatus = filter);
                  _fetchData();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryRed : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryRed : Colors.grey.shade300,
                  ),
                   boxShadow: isSelected 
                      ? [BoxShadow(color: AppColors.primaryRed.withOpacity(0.3), blurRadius: 4, offset: const Offset(0,2))]
                      : null,
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showDateRangePicker() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DateRangePickerSheet(
        initialStartDate: _dateFrom,
        initialEndDate: _dateTo,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _dateFrom = result['start'];
        _dateTo = result['end'];
      });
      _fetchData(); // Refresh with new date filter
    }
  }
}