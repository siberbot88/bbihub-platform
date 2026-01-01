import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/auth_provider.dart';
import '../providers/admin_service_provider.dart';
import '../../../../core/models/service.dart';
import 'service_detail_page.dart';

class ServiceHistoryAdminPage extends StatefulWidget {
  const ServiceHistoryAdminPage({super.key});

  @override
  State<ServiceHistoryAdminPage> createState() => _ServiceHistoryAdminPageState();
}

class _ServiceHistoryAdminPageState extends State<ServiceHistoryAdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ["Harian", "Mingguan", "Bulanan"];
  DateTime _selectedDate = DateTime.now();

  final TextEditingController _searchController = TextEditingController();
  
  // Pagination State
  int _page = 1;
  bool _isLoadingMore = false;
  
  // Debounce for search
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    // Initial Fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData(page: 1);
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _page = 1; // Reset to page 1 on tab change
    _fetchData(page: 1);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _page = 1;
      _fetchData(page: 1);
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + offset, _selectedDate.day);
    });
    _page = 1;
    _fetchData(page: 1);
  }

  void _fetchData({required int page}) {
    final provider = context.read<AdminServiceProvider>();
    final now = _selectedDate; // Use selected date instead of DateTime.now()
    String? dateFrom;
    String? dateTo;

    // Filter logic based on Tabs
    switch (_tabController.index) {
      case 0: // Harian (Uses Selected Date)
        /* 
           Note: 'Harian' logic in original code used DateTime.now().
           If we want 'Harian' to be navigable too,/ we should use _selectedDate.
           Let's assume Harian is always TODAY for now unless user requested navigating days too.
           User specifically asked for "Month navigation".
           But let's make it consistent: _selectedDate drives the view.
        */
        dateFrom = DateFormat('yyyy-MM-dd').format(now);
        dateTo = DateFormat('yyyy-MM-dd').format(now);
        break;
      case 1: // Mingguan
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        dateFrom = DateFormat('yyyy-MM-dd').format(startOfWeek);
        dateTo = DateFormat('yyyy-MM-dd').format(endOfWeek);
        break;
      case 2: // Bulanan
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        dateFrom = DateFormat('yyyy-MM-dd').format(startOfMonth);
        dateTo = DateFormat('yyyy-MM-dd').format(endOfMonth);
        break;
    }

    final auth = context.read<AuthProvider>();
    final workshopUuid = auth.user?.workshopUuid;
    
    print('🔍 Fetching history: page=$page, search=${_searchController.text}, dateFrom=$dateFrom, dateTo=$dateTo');
    
    // Update local page state
    setState(() {
      _page = page;
    });

    provider.fetchServices(
      page: page,
      dateFrom: dateFrom,
      dateTo: dateTo,
      workshopUuid: workshopUuid,
      status: null,
      dateColumn: 'completed_at',
      useScheduleEndpoint: false,
      search: _searchController.text, // Pass search query
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          "Riwayat Servis",
          style: AppTextStyles.heading4(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari nama, plat nomor, atau kode...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // Tab Selector
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(30), 
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              indicatorPadding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              dividerColor: Colors.transparent,
              labelColor: AppColors.primaryRed,
              unselectedLabelColor: Colors.grey,
              labelStyle: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.bold),
              unselectedLabelStyle: AppTextStyles.bodyMedium(),
              tabs: _tabs.map((t) => SizedBox(
                height: 40,
                child: Center(child: Text(t)),
              )).toList(),
            ),
          ),
          
          const SizedBox(height: 16),

          // Month Navigator (Only for Bulanan tab)
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, child) {
              if (_tabController.index == 2) { // Bulanan
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => _changeMonth(-1),
                      ),
                      Text(
                        DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate),
                        style: AppTextStyles.heading5(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => _changeMonth(1),
                      ),
                    ],
                  ),
                ); 
              }
              // Optional: Date picker for Harian/Mingguan could be added here
              return const SizedBox.shrink();
            },
          ),
          
          // List Content
          Expanded(
            child: Consumer<AdminServiceProvider>(
              builder: (context, provider, child) {
                if (provider.loading && provider.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.items.isEmpty) {
                  return _buildEmptyState();
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: provider.items.length,
                        itemBuilder: (context, index) {
                          final service = provider.items[index];
                          return _buildAnimatedItem(
                            GestureDetector(
                              onTap: () {
                                 Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => ServiceDetailPage(service: service)),
                                 );
                              },
                              child: _buildHistoryCard(service),
                            ),
                            index,
                          );
                        },
                      ),
                    ),
                    
                    // Pagination Controls
                    if (provider.totalPages > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: provider.hasPrevPage 
                                ? () => _fetchData(page: provider.currentPage - 1) 
                                : null,
                              icon: Icon(Icons.chevron_left, color: provider.hasPrevPage ? Colors.black : Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "Halaman ${provider.currentPage} dari ${provider.totalPages}",
                              style: AppTextStyles.bodyMedium(),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: provider.hasNextPage 
                                ? () => _fetchData(page: provider.currentPage + 1) 
                                : null,
                              icon: Icon(Icons.chevron_right, color: provider.hasNextPage ? Colors.black : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Belum ada riwayat servis",
            style: AppTextStyles.heading5(color: Colors.grey),
          ),
          if (_searchController.text.isNotEmpty)
             Text(
              "Coba kata kunci lain",
              style: AppTextStyles.bodyMedium(color: Colors.grey),
             ),
        ],
      ),
    );
  }

  // Helper for animated list item
  Widget _buildAnimatedItem(Widget child, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)), // Slide up
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildHistoryCard(ServiceModel service) {
    bool isCancelled = service.status.toLowerCase() == 'cancelled';
    bool isCompleted = service.status.toLowerCase() == 'completed' || 
                       service.status.toLowerCase() == 'selesai' ||
                       service.status.toLowerCase() == 'lunas';
    
    // Check Transaction Status First
    String displayStatus = service.status.toUpperCase();
    bool isPaid = false;

    if (service.transaction != null) {
      final tStatus = service.transaction!['status']?.toString().toLowerCase();
      if (tStatus == 'success' || tStatus == 'paid') {
        isPaid = true;
        displayStatus = 'LUNAS';
      } else if (tStatus == 'pending' && isCompleted) {
         displayStatus = 'MENUNGGU BAYAR';
      }
    }
    
    // Status Color
    Color statusColor;
    if (isPaid) statusColor = AppColors.success; // LUNAS is always Green
    else if (isCancelled) statusColor = AppColors.error;
    else if (displayStatus == 'MENUNGGU BAYAR') statusColor = Colors.orange;
    else if (isCompleted) statusColor = Colors.blue; // Completed but maybe not paid or no logic
    else statusColor = Colors.orange; // In Progress / Pending Service

    return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // border: Border.all(color: Colors.grey.shade100), // Clean border
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Indicator Strip
                Container(
                  width: 6,
                  color: statusColor,
                ),
                
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Name & Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                service.displayCustomerName,
                                style: AppTextStyles.heading4().copyWith(fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                displayStatus, // Use computed display status
                                style: AppTextStyles.caption(color: statusColor).copyWith(fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // Vehicle Info
                        Row(
                          children: [
                            Icon(Icons.directions_car_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              "${service.displayVehicleBrand} ${service.displayVehicleModel} • ${service.displayVehiclePlate}",
                              style: AppTextStyles.caption(color: AppColors.textSecondary),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        const Divider(height: 1, thickness: 0.5),
                        const SizedBox(height: 12),

                        // Service Detals
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Row(
                                  children: [
                                    Icon(Icons.build_circle_outlined, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(service.name, style: AppTextStyles.bodyMedium(color: Colors.black87)),
                                  ],
                                 ),
                                 const SizedBox(height: 4),
                                 if (service.scheduledDate != null)
                                   Row(
                                    children: [
                                      Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('dd MMM yyyy, HH:mm').format(service.scheduledDate!),
                                        style: AppTextStyles.caption(color: Colors.grey[500]),
                                      ),
                                    ],
                                   ),
                               ],
                             ),
                             
                             // Price (if any)
                             if (service.price != null && service.price! > 0)
                               Text(
                                 NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(service.price),
                                 style: AppTextStyles.heading5(color: AppColors.primaryRed),
                               )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
