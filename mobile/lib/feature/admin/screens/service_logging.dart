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
  
  List<ServiceModel> _activeServices = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final services = await context.read<AdminServiceProvider>().fetchActiveServices();
      setState(() {
        _activeServices = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  bool _matchesFilterKey(ServiceModel t, String filterKey) {
    if (filterKey == 'All') return true;
    final status = (t.status ?? '').toLowerCase();
    switch (filterKey) {
      case 'Pending':
        return status == 'pending';
      case 'In Progress':
        return status == 'in_progress' || status == 'on_process' || status == 'in progress';
      case 'Completed':
        return status == 'completed';
      default:
        return false;
    }
  }

  List<ServiceModel> _getFilteredTasks(List<ServiceModel> allServices) {
    return allServices.where((service) {
      // 1. Must be Accepted by Admin (already filtered by backend)
      // if ((service.acceptanceStatus ?? '').toLowerCase() != 'accepted') return false;

      // 2. Status Filter
      bool statusMatch = _matchesFilterKey(service, selectedLoggingFilter);
      if (!statusMatch) return false;

      // 3. Search Text
      if (searchText.trim().isNotEmpty) {
        final q = searchText.toLowerCase();
        final title = (service.name ?? '').toLowerCase();
        final plate = (service.displayVehiclePlate).toLowerCase();
        final user = (service.displayCustomerName).toLowerCase();
        
        return title.contains(q) || plate.contains(q) || user.contains(q);
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate counts from active services
    final pendingCount = _activeServices.where((s) => (s.status ?? '').toLowerCase() == 'pending').length;
    final inProgressCount = _activeServices.where((s) => ['in_progress', 'on_process', 'in progress'].contains((s.status ?? '').toLowerCase())).length;
    final completedCount = _activeServices.where((s) => (s.status ?? '').toLowerCase() == 'completed').length;

    // Filter for List
    final displayedTasks = _getFilteredTasks(_activeServices);

    return Stack(
        children: [
          // 1. Background Layer (Summary Cards)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: const Color(0xFFF8F9FA),
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              child: LoggingSummaryBoxes(
                pending: pendingCount,
                inProgress: inProgressCount,
                completed: completedCount,
              ),
            ),
          ),

          // 2. Foreground Layer (Scrolling Content)
          Positioned.fill(
            child: _buildScrollableBody(context, displayedTasks, _isLoading),
          ),
        ],
      );
  }

  Widget _buildScrollableBody(BuildContext context, List<ServiceModel> tasks, bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 90),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transparent Spacer
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
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Calendar Strip
                LoggingCalendar(
                  selectedDate: selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      selectedDate = date;
                    });
                    _fetchData();
                  },
                ),

                const SizedBox(height: 16),

                // Search & Filter Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              searchText = val;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: "Cari pelanggan atau plat nomor...",
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Filter Tabs
                      LoggingFilterTabs(
                        selectedFilter: selectedLoggingFilter,
                        onFilterChanged: (filter) {
                          setState(() {
                            selectedLoggingFilter = filter;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Task List
                if (isLoading)
                   const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                else if (tasks.isEmpty)
                   Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            "Tidak ada servis ditemukan",
                            style: AppTextStyles.bodyMedium(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (ctx, index) {
                      return LoggingTaskCard(service: tasks[index]);
                    },
                  ),
                  
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}