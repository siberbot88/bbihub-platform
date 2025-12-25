import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import 'service_logging.dart';
import '../widgets/custom_header.dart';
import '../widgets/service/service_tab_selector.dart';
import '../widgets/service/service_calendar_section.dart';
import '../widgets/service/service_card.dart';

import 'package:bengkel_online_flutter/feature/admin/providers/admin_service_provider.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:intl/intl.dart';

class ServicePageAdmin extends StatefulWidget {
  const ServicePageAdmin({super.key});

  @override
  State<ServicePageAdmin> createState() => _ServicePageAdminState();
}

class _ServicePageAdminState extends State<ServicePageAdmin> {
  int displayedMonth = DateTime.now().month;
  int displayedYear = DateTime.now().year;
  int selectedDay = DateTime.now().day;
  String selectedFilter = "All";
  int selectedTab = 0; // 0 = Scheduled, 1 = Logging

  DateTime get selectedDate =>
      DateTime(displayedYear, displayedMonth, selectedDay);
      
  /// Strict filter: Hanya menampilkan service dengan acceptance_status == 'pending'
  /// Ini adalah permintaan baru/request yang BELUM di-accept/decline.

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
    
    context.read<AdminServiceProvider>().fetchServices(
      dateFrom: dateStr,
      dateTo: dateStr,
      status: 'pending', // Sesuai request: acceptance_status pending
      workshopUuid: workshopUuid,
    );
  }

  bool _matchesFilterKey(ServiceModel s, String filterKey) {
    if (filterKey == 'All') return true;
    return s.status.toLowerCase() == filterKey.toLowerCase();
  }

  // Karena sudah difilter di API, local filtering schedule date bisa disederhanakan 
  // atau tetap dipertahankan sebagai dual-check.
  // Namun, request user: "menampilkan service berdasarkan tanggal yang dipilih"
  // Kalau API sudah return services di tanggal itu, maka list sudah sesuai.
  List<ServiceModel> _getScheduledServices(List<ServiceModel> all) {
    return all;
  }

  void _prevMonth() {
    setState(() {
      displayedMonth--;
      if (displayedMonth < 1) {
        displayedMonth = 12;
        displayedYear--;
      }
      selectedDay = 1;
    });
    _fetchData();
  }

  void _nextMonth() {
    setState(() {
      displayedMonth++;
      if (displayedMonth > 12) {
        displayedMonth = 1;
        displayedYear++;
      }
      selectedDay = 1;
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminServiceProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const CustomHeader(
        title: "Service",
        showBack: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          ServiceTabSelector(
            selectedTab: selectedTab,
            onTabChanged: (index) => setState(() => selectedTab = index),
          ),
          Expanded(
            child: IndexedStack(
              index: selectedTab,
              children: [
                _buildScheduledTab(provider),
                const ServiceLoggingPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledTab(AdminServiceProvider provider) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Text(
          provider.error!,
          style: AppTextStyles.bodyMedium(color: AppColors.error),
        ),
      );
    }

    final scheduled = _getScheduledServices(provider.items);

    return SingleChildScrollView(
      padding:  const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          ServiceCalendarSection(
            displayedMonth: displayedMonth,
            displayedYear: displayedYear,
            selectedDay: selectedDay,
            onPrevMonth: _prevMonth,
            onNextMonth: _nextMonth,
            onDaySelected: (day) {
              setState(() => selectedDay = day);
              _fetchData();
            },
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: scheduled.isEmpty
                ? Center(
              child: Text(
                "No scheduled tasks",
                style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
              ),
            )
                : Column(
              // Strict Filter: Only show services where acceptance_status is 'pending'
              // This is the "Inbox" / "Request" list for new orders.
              children: scheduled.where((s) {
                 final acceptStatus = (s.acceptanceStatus ?? '').toLowerCase();
                 // Show strict pending only
                 return acceptStatus == 'pending';
              }).map((s) {
                return ServiceCard(service: s);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
