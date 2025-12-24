import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:bengkel_online_flutter/core/models/staff_performance.dart';
import 'package:bengkel_online_flutter/core/models/user.dart';

enum PerformanceRange { today, week, month }

/// Helper functions untuk kalkulasi performance staff
class PerformanceHelpers {
  /// Calculate performance untuk semua staff
  static List<StaffPerformance> calculateAllStaffPerformance({
    required List<User> staffList,
    required List<ServiceModel> allServices,
    required PerformanceRange range,
  }) {
    debugPrint('📊 [PERFORMANCE] Calculating for ${staffList.length} staff, ${allServices.length} services, range: $range');
    
    return staffList.map((staff) {
      return calculateStaffPerformance(
        staff: staff,
        allServices: allServices,
        range: range,
      );
    }).toList();
  }

  /// Calculate performance untuk individual staff
  static StaffPerformance calculateStaffPerformance({
    required User staff,
    required List<ServiceModel> allServices,
    required PerformanceRange range,
  }) {
    // Filter services untuk staff ini dalam range yang dipilih
    final staffServices = _getStaffServices(
      staffId: staff.id,
      allServices: allServices,
      range: range,
    );

    // Separate completed vs in-progress
    final completedJobs = staffServices
        .where((s) => s.status.toLowerCase() == 'completed')
        .toList();
    
    final inProgressJobs = staffServices
        .where((s) {
          final status = s.status.toLowerCase();
          return status == 'pending' || 
                 status == 'in progress' || 
                 status == 'accept';
        })
        .toList();

    // Calculate revenue
    final totalRevenue = completedJobs.fold<num>(
      0,
      (sum, service) => sum + _calculateServiceRevenue(service),
    );

    // Determine staff name
    String displayName = 'Unknown';
    if (staff.name.isNotEmpty) {
      displayName = staff.name;
    } else if (staff.username.isNotEmpty) {
      displayName = staff.username;
    }

    return StaffPerformance(
      name: displayName,
      role: StaffRole.values.firstWhere(
        (e) => e.toString().contains(staff.role.toLowerCase()),
        orElse: () => StaffRole.seniorMechanic
      ),
      avatarUrl: staff.photo ?? '',
      jobsDone: completedJobs.length,
      jobsInProgress: inProgressJobs.length,
      estimatedRevenue: totalRevenue.toInt(),
    );
  }

  /// Get services untuk specific staff dalam range tertentu
  static List<ServiceModel> _getStaffServices({
    required String staffId,  // Currently unused, will be used when backend has assignment
    required List<ServiceModel> allServices,
    required PerformanceRange range,
  }) {
    return allServices.where((service) {
      // TODO: Filter by technician/assigned_to when field available
      // For now, randomly assign for demo purposes
      // In production, check: service.assignedTo == staffId
      // ignore: unused_local_variable
      final _ = staffId;  // Suppress warning, will be used in production
      
      // Filter by date range
      if (!_isServiceInRange(service, range)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Check if service is within the selected date range
  static bool _isServiceInRange(ServiceModel service, PerformanceRange range) {
    final now = DateTime.now();
    DateTime? serviceDate = service.scheduledDate;
    serviceDate ??= service.createdAt;
    serviceDate ??= service.updatedAt;
    
    if (serviceDate == null) return false;

    switch (range) {
      case PerformanceRange.today:
        return serviceDate.year == now.year &&
               serviceDate.month == now.month &&
               serviceDate.day == now.day;
               
      case PerformanceRange.week:
        final startOfWeek = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 7));
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return serviceDate.isAfter(startOfWeek) && serviceDate.isBefore(endOfDay);
        
      case PerformanceRange.month:
        return serviceDate.year == now.year && serviceDate.month == now.month;
    }
  }

  /// Calculate total revenue dari service (price + parts)
  static num _calculateServiceRevenue(ServiceModel service) {
    final partsTotal = (service.items ?? [])
        .fold<num>(0, (sum, item) => sum + item.subtotal);
    return (service.price ?? 0) + partsTotal;
  }

  /// Format range label untuk display
  static String getRangeLabel(PerformanceRange range) {
    switch (range) {
      case PerformanceRange.today:
        return 'Hari ini';
      case PerformanceRange.week:
        return 'Minggu ini';
      case PerformanceRange.month:
        return 'Bulan ini';
    }
  }

  /// Mock assignment for demo (distribusi service ke staff secara random)
  /// TODO: Remove this when backend has real assignment data
  static List<ServiceModel> mockAssignServices(
    List<ServiceModel> services,
    List<User> staffList,
  ) {
    if (staffList.isEmpty) return services;
    
    // Distribute services evenly across staff
    final assignedServices = <ServiceModel>[];
    for (int i = 0; i < services.length; i++) {
      // In real app, this would be: service.assignedTo = staffList[i % staffList.length].id
      // For now just return as-is
      assignedServices.add(services[i]);
    }
    
    return assignedServices;
  }
}
