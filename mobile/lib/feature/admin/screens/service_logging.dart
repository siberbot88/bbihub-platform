import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bengkel_online_flutter/feature/admin/providers/admin_service_provider.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/core/models/customer.dart';
import 'package:bengkel_online_flutter/core/models/vehicle.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';
import '../widgets/service_logging/logging_summary_boxes.dart';
import '../widgets/service_logging/logging_calendar.dart';
import '../widgets/service_logging/logging_filter_tabs.dart';
import '../widgets/service_logging/logging_task_card.dart';

class ServiceLoggingPage extends StatefulWidget {
  const ServiceLoggingPage({super.key});

  @override
  State<ServiceLoggingPage> createState() => _ServiceLoggingPageState();
}

class _ServiceLoggingPageState extends State<ServiceLoggingPage> {
  DateTime selectedDate = DateTime.now();

  String searchText = "";
  String selectedLoggingFilter = "All";
  String? selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    final auth = context.read<AuthProvider>();
    final workshopUuid = auth.user?.workshopUuid;
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    // Fetch ALL services for the date, then we filter client-side if needed for 'accepted' status
    // Or if API supports filtering by acceptance_status, use that.
    // Assuming API 'status' param maps to service status (pending, in_progress, etc), not acceptance.
    // So we fetch by date and workshop, then filter for acceptanceStatus == 'accepted'.
    
    context.read<AdminServiceProvider>().fetchServices(
      dateFrom: dateStr,
      dateTo: dateStr,
      workshopUuid: workshopUuid,
      // We don't limit by status here because logging page shows Pending (Mechanic), In Progress, and Completed.
      // But we MUST exclude those that are NOT accepted yet (handled in filtering later).
    );
  }



  bool _matchesFilterKey(ServiceModel t, String filterKey) {
    if (filterKey == 'All') return true;
    final status = (t.status ?? '').toLowerCase();
    switch (filterKey) {
      case 'Pending':
        // Di logging page, 'Pending' berarti Accepted but waiting for Mechanic
        return status == 'pending';
      case 'In Progress':
        return status == 'in_progress' || status == 'on_process';
      case 'Completed':
        return status == 'completed';
      default:
        return false;
    }
  }

  List<ServiceModel> _getFilteredTasks(List<ServiceModel> allServices) {
    return allServices.where((service) {
      // 1. Must be Accepted by Admin
      if (service.acceptanceStatus != 'accepted') return false;

      // 2. Date match (API filters by date, but double check)
       // bool dateMatch = LoggingHelpers.isSameDate(service.scheduledDate ?? DateTime.now(), selectedDate);
       // if (!dateMatch) return false;

      // 3. Status Filter (Tabs)
      bool statusMatch = _matchesFilterKey(service, selectedLoggingFilter);
      if (!statusMatch) return false;

      // 4. Time Slot Filter
      // Assuming time match logic based on hours
      if (selectedTimeSlot != null) {
        // Simple string match or parsing. Current implementation is string based.
        // Let's rely on string match for now if service has time property, otherwise skip or implement better time logic later.
        // For now, let's ignore time slot filter if model doesn't support it well, or try to match formatted time.
        // if (task['time'] != selectedTimeSlot) return false;
      }

      // 5. Search Text
      if (searchText.trim().isNotEmpty) {
        final q = searchText.toLowerCase();
        final title = (service.name).toLowerCase();
        final plate = (service.displayVehiclePlate).toLowerCase();
        final user = (service.displayCustomerName).toLowerCase();
        
        return title.contains(q) || plate.contains(q) || user.contains(q);
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminServiceProvider>();
    
    // Create Dummy Data
    final dummyServices = [
       ServiceModel(
        id: '991',
        code: 'SRV-DEMO-001',
        name: 'Ganti Oli Mesin',
        description: 'Ganti oli rutin motul',
        price: 50000,
        status: 'pending',
        acceptanceStatus: 'accepted',
        customer: Customer(id: 'c1', name: 'Budi Santoso', phone: '08123456789'),
        vehicle: Vehicle(id: 'v1', plateNumber: 'B 1234 ABC', brand: 'Honda', model: 'Beat', name: 'Beat Hitam'),
        scheduledDate: DateTime.now(),
      ),
      ServiceModel(
        id: '992',
        code: 'SRV-DEMO-002',
        name: 'Servis CVT',
        description: 'Bunyi gredek saat tarikan awal',
        price: 150000,
        status: 'pending', // Waiting for mechanic
        acceptanceStatus: 'accepted',
        customer: Customer(id: 'c2', name: 'Siti Aminah', phone: '08129876543'),
        vehicle: Vehicle(id: 'v2', plateNumber: 'B 4567 XYZ', brand: 'Yamaha', model: 'NMAX', name: 'NMAX Putih'),
        scheduledDate: DateTime.now(),
      ),
      ServiceModel(
        id: '993',
        code: 'SRV-DEMO-003',
        name: 'Ganti Ban Belakang',
        description: 'Ban sudah botak',
        price: 300000,
        status: 'in_progress',
        acceptanceStatus: 'accepted',
        mechanicUuid: 'm1',
        mechanic: MechanicRef(id: 'm1', name: 'Joko Susilio'),
        customer: Customer(id: 'c3', name: 'Ahmad Rizky', phone: '08134567890'),
        vehicle: Vehicle(id: 'v3', plateNumber: 'D 8888 AA', brand: 'Honda', model: 'Vario 150', name: 'Vario Merah'),
        scheduledDate: DateTime.now(),
      ),
      ServiceModel(
        id: '994',
        code: 'SRV-DEMO-004',
        name: 'Tune Up Ringan',
        description: 'Servis rutin bulanan',
        price: 75000,
        status: 'in_progress',
        acceptanceStatus: 'accepted',
        mechanicUuid: 'm2',
        mechanic: MechanicRef(id: 'm2', name: 'Dhani Ahmad'),
        customer: Customer(id: 'c4', name: 'Dewi Persik', phone: '08135555666'),
        vehicle: Vehicle(id: 'v4', plateNumber: 'L 1234 BB', brand: 'Yamaha', model: 'Mio', name: 'Mio Biru'),
        scheduledDate: DateTime.now(),
      ),
       ServiceModel(
        id: '995',
        code: 'SRV-DEMO-005',
        name: 'Ganti Kampas Rem',
        description: 'Rem depan bunyi',
        price: 45000,
        status: 'completed',
        acceptanceStatus: 'accepted',
        mechanicUuid: 'm1',
        mechanic: MechanicRef(id: 'm1', name: 'Joko Susilio'),
        customer: Customer(id: 'c5', name: 'Raffi Ahmad', phone: '08177778888'),
        vehicle: Vehicle(id: 'v5', plateNumber: 'B 1 R', brand: 'Vespa', model: 'Sprint', name: 'Vespa Kuning'),
        scheduledDate: DateTime.now(),
        completedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    // Combine provider items with dummy items
    final allServices = [...provider.items, ...dummyServices];

    // Filter for accepted services strictly
    // API returns all services for the date. We filter client side.
    final acceptedServicesForDate = allServices.where((s) {
       final acc = (s.acceptanceStatus ?? '').toLowerCase();
       return acc == 'accepted';
    }).toList();

    // Categorize based on Service Status
    final pending = acceptedServicesForDate
        .where((t) => (t.status ?? '').toLowerCase() == 'pending')
        .length;
        
    final inProgress = acceptedServicesForDate
        .where((t) => (t.status ?? '').toLowerCase() == 'in_progress' || (t.status ?? '').toLowerCase() == 'on_process')
        .length;
        
    final completed = acceptedServicesForDate
        .where((t) => (t.status ?? '').toLowerCase() == 'completed')
        .length;

    final loggingFiltered = _getFilteredTasks(allServices);
    final title = selectedTimeSlot == null
        ? "Semua Tugas"
        : "Tugas untuk jam $selectedTimeSlot"; // Time slot logic is pending proper implementation

    return Stack(
      children: [
        // 1. Background Layer (Summary Cards)
        // Fixed at top, allowing list to slide over it
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: const Color(0xFFF8F9FA), // Match scaffold background
            padding: const EdgeInsets.only(top: 8, bottom: 24), // Extra bottom padding for overlap area
            child: LoggingSummaryBoxes(
              pending: pending,
              inProgress: inProgress,
              completed: completed,
            ),
          ),
        ),

        // 2. Foreground Layer (Scrolling Content)
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 90),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transparent Spacer to reveal Summary Cards initially
                // Height must match the visual height of LoggingSummaryBoxes + top padding
                // Estimated: 8 (top pad) + 132 (widget height approx) + 16 (extra spacing)
                const SizedBox(height: 160), 

                // The White Sheet Content
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      // Date Navigation Header
                       Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
                                onPressed: () {
                                  setState(() {
                                     selectedDate = selectedDate.subtract(const Duration(days: 1));
                                  });
                                  _fetchData();
                                },
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: selectedDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: const ColorScheme.light(
                                              primary: AppColors.primaryRed,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null && picked != selectedDate) {
                                      setState(() {
                                        selectedDate = picked;
                                      });
                                      _fetchData();
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                       const Icon(Icons.calendar_month, color: AppColors.primaryRed, size: 20),
                                       const SizedBox(width: 8),
                                       Flexible(
                                         child: Text(
                                           DateFormat('EEEE, d MMMM yyyy').format(selectedDate),
                                           style: AppTextStyles.heading5(),
                                           overflow: TextOverflow.ellipsis,
                                         ),
                                       ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
                                onPressed: () {
                                  setState(() {
                                     selectedDate = selectedDate.add(const Duration(days: 1));
                                  });
                                   _fetchData();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSearchBar(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: LoggingFilterTabs(
                          selectedFilter: selectedLoggingFilter,
                          onFilterChanged: (filter) =>
                              setState(() => selectedLoggingFilter = filter),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLoggingContent(title, loggingFiltered),
                      const SizedBox(height: 80), // Extra space for bottom fab/nav
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
                child: TextField(
                decoration: InputDecoration.collapsed(
                  hintText: "Search logging...",
                  hintStyle: AppTextStyles.caption(),
                ),
                style: AppTextStyles.bodyMedium(),
                onChanged: (val) => setState(() => searchText = val),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.grey),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggingContent(
      String title, List<ServiceModel> loggingFiltered) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.heading4(),
          ),
          const SizedBox(height: 12),
          if (loggingFiltered.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "Tidak ada tugas yang sesuai dengan filter.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...loggingFiltered.map((t) => LoggingTaskCard(service: t)),
        ],
      ),
    );
  }


}