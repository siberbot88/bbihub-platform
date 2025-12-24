import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bengkel_online_flutter/feature/admin/providers/admin_service_provider.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';
import '../widgets/service_logging/logging_summary_boxes.dart';
import '../widgets/service_logging/logging_calendar.dart';
import '../widgets/service_logging/logging_filter_tabs.dart';
import '../widgets/service_logging/logging_time_slots.dart';
import '../widgets/service_logging/logging_task_card.dart';
import '../widgets/service_logging/logging_helpers.dart';

class ServiceLoggingPage extends StatefulWidget {
  const ServiceLoggingPage({super.key});

  @override
  State<ServiceLoggingPage> createState() => _ServiceLoggingPageState();
}

class _ServiceLoggingPageState extends State<ServiceLoggingPage> {
  int displayedMonth = DateTime.now().month;
  int displayedYear = DateTime.now().year;
  int selectedDay = DateTime.now().day;

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

  DateTime get selectedDate =>
      DateTime(displayedYear, displayedMonth, selectedDay);

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
    final allServices = provider.items;

    // Filter for accepted services strictly
    // API returns all services for the date. We filter client side.
    final acceptedServicesForDate = allServices.where((s) {
       final acc = (s.acceptanceStatus ?? '').toLowerCase();
       return acc == 'accepted';
    }).toList();

    // Categorize based on Service Status
    // Pending: Accepted by Admin, but "status" is still pending (Waiting for Mechanic)
    final pending = acceptedServicesForDate
        .where((t) => (t.status ?? '').toLowerCase() == 'pending')
        .length;
        
    // In Progress: Mechanic Assigned
    final inProgress = acceptedServicesForDate
        .where((t) => (t.status ?? '').toLowerCase() == 'in_progress' || (t.status ?? '').toLowerCase() == 'on_process')
        .length;
        
    // Completed
    final completed = acceptedServicesForDate
        .where((t) => (t.status ?? '').toLowerCase() == 'completed')
        .length;

    final loggingFiltered = _getFilteredTasks(allServices);
    final title = selectedTimeSlot == null
        ? "Semua Tugas"
        : "Tugas untuk jam $selectedTimeSlot"; // Time slot logic is pending proper implementation

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          LoggingSummaryBoxes(
            pending: pending,
            inProgress: inProgress,
            completed: completed,
          ),
          const SizedBox(height: 12),
          LoggingCalendar(
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
          _buildSearchBar(),
          const SizedBox(height: 12),
          LoggingFilterTabs(
            selectedFilter: selectedLoggingFilter,
            onFilterChanged: (filter) =>
                setState(() => selectedLoggingFilter = filter),
          ),
          const SizedBox(height: 12),
          if (selectedLoggingFilter == "All") ...[
            // Padding for timeslots if we implement logic later
            // LoggingTimeSlots(...), 
            // const SizedBox(height: 12),
          ],
          _buildLoggingContent(title, loggingFiltered),
        ],
      ),
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
      String title, List<ServiceModel> filtered) {
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
          if (filtered.isEmpty)
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
            ...filtered.map((t) => LoggingTaskCard(service: t)),
        ],
      ),
    );
  }

  void _prevMonth() => setState(() {
        displayedMonth -= 1;
        if (displayedMonth < 1) {
          displayedMonth = 12;
          displayedYear -= 1;
        }
        selectedDay = 1;
        _fetchData();
      });

  void _nextMonth() => setState(() {
        displayedMonth += 1;
        if (displayedMonth > 12) {
          displayedMonth = 1;
          displayedYear += 1;
        }
        selectedDay = 1;
        _fetchData();
      });
}