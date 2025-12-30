import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

// Providers & Models
import 'package:bengkel_online_flutter/feature/admin/providers/admin_service_provider.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';

// Screens
import 'add_service_onsite_page.dart';
import 'service_history_page.dart';
import 'service_logging.dart';
import 'service_detail_page.dart';

// Widgets
import '../widgets/service/service_card_admin.dart';

class ServicePageAdmin extends StatefulWidget {
  const ServicePageAdmin({super.key});

  @override
  State<ServicePageAdmin> createState() => _ServicePageAdminState();
}

class _ServicePageAdminState extends State<ServicePageAdmin> with SingleTickerProviderStateMixin {
  int _mainMode = 0; // 0 = Penjadwalan, 1 = Pencatatan

  // Penjadwalan State
  // Penjadwalan State
  // Status filtering removed as per request


  String _selectedTypeFilter = 'Semua Tipe';
  final List<String> _typeFilters = ['Semua Tipe', 'Booking', 'Ditempat']; // 'Ditempat' = Onsite
  
  late DateTimeRange _selectedDateRange;

  @override
  void initState() {
    super.initState();
    // Default range: 1st of Month until Now
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );

    // Initial fetch for Penjadwalan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSchedulingData();
    });
  }

  void _fetchSchedulingData() {
    // Only fetch if in scheduling mode
    if (_mainMode != 0) return;

    final auth = context.read<AuthProvider>();
    final workshopUuid = auth.user?.workshopUuid;
    
    String? typeFilter;
    if (_selectedTypeFilter == 'Booking') typeFilter = 'booking';
    if (_selectedTypeFilter == 'Ditempat') typeFilter = 'ditempat';

    // Fetch for the range
    context.read<AdminServiceProvider>().fetchServices(
      workshopUuid: workshopUuid,
      dateFrom: DateFormat('yyyy-MM-dd').format(_selectedDateRange.start),
      dateTo: DateFormat('yyyy-MM-dd').format(_selectedDateRange.end),
      type: typeFilter,
      // We don't filter status at API level here because tabs do client-side filtering for smooth UX (logic preserved for status)
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primaryRed,
            colorScheme: const ColorScheme.light(primary: AppColors.primaryRed),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() => _selectedDateRange = picked);
      _fetchSchedulingData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      body: Column( // Removed SafeArea
        children: [
          _buildHeader(),
          Expanded(
            child: _mainMode == 0
                ? _buildPenjadwalanView()
                : const ServiceLoggingPage(), // Pencatatan view
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24), // Added dynamic top padding
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4A0909), // Dark maroon
            Color(0xFF8B1A1A), // Maroon
            Color(0xFF9B0D0D), // Red-maroon
            Color(0xFFB70F0F), // Red
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Daftar Servis",
                style: AppTextStyles.heading4(color: Colors.white),
              ),
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.history,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ServiceHistoryAdminPage()),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    icon: Icons.add,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddServiceOnSitePage()),
                      );
                    },
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          _buildModeToggle(),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
       padding: const EdgeInsets.all(4),
       decoration: BoxDecoration(
         color: Colors.white.withOpacity(0.2),
         borderRadius: BorderRadius.circular(30),
       ),
       child: Row(
         children: [
           Expanded(
             child: _buildToggleButton(
               label: "Penjadwalan", 
               index: 0,
             ),
           ),
           Expanded(
             child: _buildToggleButton(
               label: "Pencatatan", 
               index: 1,
             ),
           ),
         ],
       ),
    );
  }

  Widget _buildToggleButton({required String label, required int index}) {
    final isSelected = _mainMode == index;
    return GestureDetector(
      onTap: () {
        if (_mainMode != index) {
          setState(() => _mainMode = index);
          if (index == 0) _fetchSchedulingData();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label, 
          style: AppTextStyles.bodyMedium(
             color: isSelected ? AppColors.primaryRed : Colors.white
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }


  Widget _buildPenjadwalanView() {
    final provider = context.watch<AdminServiceProvider>();
    final services = provider.items;
    final isLoading = provider.loading;

    // Filter & Group Logic
    final grouped = _groupServices(services);

    return Column(
      children: [
        const SizedBox(height: 16),
        const SizedBox(height: 16),

        const SizedBox(height: 12),

        // Filter Tabs (Type)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: _typeFilters.map((filter) {
              bool isSelected = _selectedTypeFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    if (_selectedTypeFilter != filter) {
                      setState(() => _selectedTypeFilter = filter);
                      _fetchSchedulingData();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Slightly smaller
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blueGrey[800] : Colors.white, // Different color info/neutral
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.blueGrey[800]! : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: AppTextStyles.caption( // Smaller text
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ).copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Date Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: _pickDateRange,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              ),
              child: Row(
                children: [
                   const Icon(Icons.calendar_month, size: 20, color: AppColors.primaryRed),
                   const SizedBox(width: 12),
                   Text(
                     _formatDateRange(_selectedDateRange),
                     style: AppTextStyles.bodyMedium(color: Colors.black87)
                         .copyWith(fontWeight: FontWeight.w500),
                   ),
                   const Spacer(),
                   Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey.shade600),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // List
        Expanded(
          child: isLoading 
              ? const Center(child: CircularProgressIndicator())
              : grouped.isEmpty
                  ? Center(child: Text("Tidak ada jadwal servis", style: AppTextStyles.bodyMedium(color: Colors.grey)))
                  : ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 80),
            physics: const BouncingScrollPhysics(),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final group = grouped[index];
              final dateHeader = group['header'] as String;
              final dayServices = group['services'] as List<ServiceModel>;
              final isToday = dateHeader == 'Hari Ini';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text(
                           dateHeader,
                           style: AppTextStyles.heading5(),
                         ),
                       ],
                     ),
                  ),
                  ...dayServices.map((service) {
                    final timeStr = service.scheduledDate != null 
                        ? DateFormat('HH:mm').format(service.scheduledDate!)
                        : '-';
                    
                    // Map backend status to UI status if needed, or use raw
                    String displayStatus = service.status ?? 'Pending';
                    if (service.status == 'in_progress') displayStatus = 'Proses';
                    if (service.status == 'completed') displayStatus = 'Selesai';
                    
                    return ServiceCardAdmin(
                      customerName: service.displayCustomerName,
                      vehicleName: service.displayVehicleName,
                      licensePlate: service.displayVehiclePlate,
                      serviceType: service.name,
                      time: timeStr,
                      status: displayStatus,
                      isToday: isToday,
                      onTap: () {
                         Navigator.push(
                           context,
                           MaterialPageRoute(builder: (context) => ServiceDetailPage(service: service)),
                         );
                      },
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDateRange(DateTimeRange range) {
    if (range.start.year == range.end.year) {
       return "${DateFormat('d MMM').format(range.start)} - ${DateFormat('d MMM yyyy').format(range.end)}";
    }
    return "${DateFormat('d MMM yyy').format(range.start)} - ${DateFormat('d MMM yyyy').format(range.end)}";
  }

  List<Map<String, dynamic>> _groupServices(List<ServiceModel> allServices) {
    // 1. Filter by Acceptance Status (Scheduling only shows accepted usually, or all requests? 
    // Assuming Scheduling = Accepted/Scheduled)
    // var filtered = allServices.where((s) => s.acceptanceStatus == 'accepted').toList();
    var filtered = List<ServiceModel>.from(allServices); // Show ALL loaded services (Filtered by API)

    // 2. Filter by Status Tab
    // 2. Filter by Status Tab (REMOVED)
    // if (_selectedStatusFilter != 'Semua') {
    //   filtered = filtered.where((s) {
    //     ...
    //   }).toList();
    // }

    // 3. Filter by Type (REMOVED: Handled by API)
    // if (_selectedTypeFilter != 'Semua Tipe') {
    //    filtered = filtered.where((s) { ... }).toList();
    // }

    // Sort by Date
    filtered.sort((a, b) => (a.scheduledDate ?? DateTime.now()).compareTo(b.scheduledDate ?? DateTime.now()));

    // 4. Group
    final List<Map<String, dynamic>> grouped = [];
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);


    // Grouping Implementation
    // We group by "YYYY-MM-DD" key
    final Map<String, List<ServiceModel>> map = {};
    for (var s in filtered) {
       if (s.scheduledDate == null) continue;
       final key = DateFormat('yyyy-MM-dd').format(s.scheduledDate!);
       if (map[key] == null) map[key] = [];
       map[key]!.add(s);
    }

    // Convert map to list
    map.forEach((key, list) {
       String header = key == todayStr 
           ? 'Hari Ini' 
           : DateFormat('dd MMM yyyy').format(DateTime.parse(key));
       
       grouped.add({
         'header': header,
         'services': list,
       });
    });

    return grouped;
  }
}
