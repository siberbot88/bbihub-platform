import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  
  // Date tracking
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    // Initial Fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _fetchData();
  }

  void _fetchData() {
    final provider = context.read<AdminServiceProvider>();
    final now = DateTime.now();
    String? dateFrom;
    String? dateTo;

    // Filter logic based on Tabs
    switch (_tabController.index) {
      case 0: // Harian (Today)
        dateFrom = DateFormat('yyyy-MM-dd').format(now);
        dateTo = DateFormat('yyyy-MM-dd').format(now);
        break;
      case 1: // Mingguan (This Week)
        // Find start of week (Monday)
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        dateFrom = DateFormat('yyyy-MM-dd').format(startOfWeek);
        dateTo = DateFormat('yyyy-MM-dd').format(endOfWeek);
        break;
      case 2: // Bulanan (This Month)
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        dateFrom = DateFormat('yyyy-MM-dd').format(startOfMonth);
        dateTo = DateFormat('yyyy-MM-dd').format(endOfMonth);
        break;
    }

    final auth = context.read<AuthProvider>();
    final workshopUuid = auth.user?.workshopUuid; // Fixed: workshopId -> workshopUuid
    
    print('🔍 Fetching history: dateFrom=$dateFrom, dateTo=$dateTo, workshopUuid=$workshopUuid');
    
    context.read<AdminServiceProvider>().fetchServices(
      page: 1,
      dateFrom: dateFrom,
      dateTo: dateTo,
      workshopUuid: workshopUuid, // CRITICAL: Filter by admin's workshop
      status: null, // Show all statuses, filter by date only
      dateColumn: 'completed_at', // Use completion date for history tracking
      useScheduleEndpoint: false, // Use /admins/services (flat) instead of /schedule (grouped)
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
          // Tab Selector
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4), // Add padding for better spacing
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
              indicatorPadding: EdgeInsets.zero, // Remove default padding
              labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Add padding for pill shape
              dividerColor: Colors.transparent, // Remove divider
              labelColor: AppColors.primaryRed,
              unselectedLabelColor: Colors.grey,
              labelStyle: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.bold),
              unselectedLabelStyle: AppTextStyles.bodyMedium(),
              tabs: _tabs.map((t) => SizedBox(
                height: 40, // Fixed height for pill shape
                child: Center(child: Text(t)),
              )).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
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

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: provider.items.length + 1, // +1 for loader if pagination
                  itemBuilder: (context, index) {
                    if (index == provider.items.length) {
                       return provider.loading ? const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator())) : const SizedBox();
                    }

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
    
    // Status Color
    Color statusColor;
    if (isCancelled) statusColor = AppColors.error;
    else if (isCompleted) statusColor = AppColors.success;
    else statusColor = Colors.orange;

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
                                service.status.toUpperCase(),
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
