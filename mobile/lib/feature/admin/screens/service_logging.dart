import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
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
  String _selectedTab = 'accepted';
  String? _selectedMake;
  
  // Date filter variables
  DateTime? _dateFrom;
  DateTime? _dateTo;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabController.index == 0 ? 'accepted' : 'drafts';
        });
        _fetchData();
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final services = await context.read<AdminServiceProvider>().fetchActiveServices();
      if (mounted) {
        setState(() {
          _services = services;
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
    return _services.where((service) {
      final status = (service.acceptanceStatus ?? '').toLowerCase();
      final coreStatus = (service.status ?? '').toLowerCase();
      
      if (_selectedTab == 'accepted') {
        if (status != 'accepted') return false;
        // User Request: Completed items should NOT be in "Pencatatan" even if unpaid/processing.
        // They are technically "Selesai" in terms of mechanics work.
        if (coreStatus == 'completed' || coreStatus == 'lunas') return false; 
      }
      if (_selectedTab == 'drafts' && status != 'pending') return false;
      
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final title = service.name.toLowerCase();
        final plate = (service.displayVehiclePlate).toLowerCase();
        final customer = (service.displayCustomerName).toLowerCase();
        if (!title.contains(query) && !plate.contains(query) && !customer.contains(query)) {
          return false;
        }
      }
      
      if (_selectedMake != null) {
        if (!service.name.toLowerCase().contains(_selectedMake!.toLowerCase())) {
          return false;
        }
      }
      
      return true;
    }).toList();
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
            
            _buildTabs(isDark),
            
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

  Widget _buildTabs(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primaryRed,
        indicatorWeight: 3,
        labelColor: isDark ? Colors.white : Colors.black,
        unselectedLabelColor: Colors.grey[500],
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        tabs: const [
          Tab(text: 'Accepted'),
          Tab(text: 'Drafts'),
        ],
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