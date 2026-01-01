enum TimeRange { daily, weekly, monthly }

class ReportData {
  final Map<String, double> serviceBreakdown;
  final List<double> revenueTrend;
  final List<double> jobsTrend;
  final List<String> labels;

  final int jobsDone;
  final int occupancy;
  final double avgRating;
  final int revenueThisPeriod;

  final String revenueGrowthText;
  final String jobsGrowthText;
  final String occupancyGrowthText;
  final String ratingGrowthText;

  final List<double> avgQueueBars;
  final List<double> peakHourBars;
  final List<String> peakHourLabels;

  final int avgQueue;
  final String peakRange;
  final int efficiency;
  final List<Map<String, dynamic>> forecastRevenue;
  final List<Map<String, dynamic>> topMechanics;

  ReportData({
    required this.serviceBreakdown,
    required this.revenueTrend,
    required this.jobsTrend,
    required this.labels,
    required this.jobsDone,
    required this.occupancy,
    required this.avgRating,
    required this.revenueThisPeriod,
    required this.revenueGrowthText,
    required this.jobsGrowthText,
    required this.occupancyGrowthText,
    required this.ratingGrowthText,
    required this.avgQueueBars,
    required this.peakHourBars,
    required this.peakHourLabels,
    required this.avgQueue,
    required this.peakRange,
    required this.efficiency,
    required this.forecastRevenue,
    required this.topMechanics,
  });

  static ReportData seed() {
    return ReportData(
      serviceBreakdown: const {
        'Service Rutin': 35,
        'Perbaikan': 28,
        'Ganti Onderdil': 22,
        'Body Repair': 15,
      },
      revenueTrend: const [40, 48, 43, 60, 57, 65],
      jobsTrend: const [35, 45, 40, 50, 48, 56],
      labels: const ['Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt'],
      jobsDone: 22,
      occupancy: 89,
      avgRating: 4.8,
      revenueThisPeriod: 64700000,
      revenueGrowthText: '+12,5%',
      jobsGrowthText: '+8%',
      occupancyGrowthText: '−3%',
      ratingGrowthText: '+5%',
      avgQueueBars: const [9, 12, 14, 11, 18, 22, 7],
      peakHourBars: const [28, 60, 84, 76, 88, 92, 54, 32],
      peakHourLabels: const [
        '08:00',
        '10:00',
        '12:00',
        '14:00',
        '16:00',
        '18:00',
        '20:00',
        '22:00'
      ],
      avgQueue: 15,
      peakRange: '14:00 - 18:00',
      efficiency: 92,
      forecastRevenue: [],
      topMechanics: [
        {'name': 'Budi Santoso', 'jobs_count': 12, 'rating': 4.8},
        {'name': 'Ahmad Dani', 'jobs_count': 10, 'rating': 4.5},
      ],
    );
  }

  /// Parse analytics data from backend API response
  factory ReportData.fromJson(Map<String, dynamic> json, String rangeString) {
    final metrics = json['metrics'] ?? json; // Handle flat structure if needed
    final growth = json['growth'] ?? {
       'revenue': 0, 'jobs': 0, 'occupancy': 0, 'rating': 0
    }; 
    // Backend returns 'data' which contains everything directly (step 682 AnalyticsController)
    // AnalyticsController structure:
    // data: { revenue_this_period, jobs_done, ..., revenue_trend, forecast_revenue ... }
    
    // Check if we are receiving the aggregated structure from AnalyticsController
    final isAggregated = json.containsKey('revenue_this_period');
    
    // Helper to safely get value
    T safeGet<T>(String key, T def) => json[key] is T ? json[key] : def;
    
    // Service Breakdown - handle both Map and List (defensive)
    Map<String, double> serviceBreakdown = {};
    try {
      final sbData = json['service_breakdown'];
      if (sbData is Map<String, dynamic>) {
        serviceBreakdown = sbData.map((key, value) => MapEntry(key, (value as num).toDouble()));
      } else if (sbData is List) {
        // If it's a list, convert to empty map
        print('Warning: service_breakdown is List, expected Map');
        serviceBreakdown = {};
      }
    } catch (e) {
      print('Error parsing service_breakdown: $e');
    }

    // Forecast - defensive handling
    List<Map<String, dynamic>> forecastList = [];
    try {
      final fcData = json['forecast_revenue'];
      if (fcData is List) {
        forecastList = fcData.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      print('Error parsing forecast_revenue: $e');
    }

    // Top Mechanics - defensive handling  
    List<Map<String, dynamic>> topMechList = [];
    try {
      final tmData = json['top_mechanics'];
      if (tmData is List) {
        topMechList = tmData.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      print('Error parsing top_mechanics: $e');
    }

    // Trend
    final revenueTrend = (json['revenue_trend'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [];
    final jobsTrend = (json['jobs_trend'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [];
    final labels = (json['trend_labels'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    return ReportData(
      serviceBreakdown: serviceBreakdown,
      revenueTrend: revenueTrend,
      jobsTrend: jobsTrend,
      labels: labels,
      jobsDone: safeGet('jobs_done', 0),
      occupancy: safeGet('occupancy_rate', 0),
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      revenueThisPeriod: safeGet('revenue_this_period', 0),
      revenueGrowthText: json['revenue_growth_text'] ?? '+0%',
      jobsGrowthText: json['jobs_growth_text'] ?? '+0%',
      occupancyGrowthText: json['occupancy_growth_text'] ?? '0%',
      ratingGrowthText: json['rating_growth_text'] ?? '0%',
      avgQueueBars: (json['avg_queue_bars'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [],
      peakHourBars: (json['peak_hour_bars'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [],
      peakHourLabels: (json['peak_hour_labels'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      avgQueue: safeGet('avg_queue', 0),
      peakRange: json['peak_range'] ?? '-',
      efficiency: safeGet('efficiency', 0),
      forecastRevenue: forecastList,
      topMechanics: topMechList,
    );
  }


  ReportData forRange(TimeRange r) {
    if (r == TimeRange.monthly) return this;

    if (r == TimeRange.weekly) {
      return ReportData(
        serviceBreakdown: serviceBreakdown,
        revenueTrend: const [8, 10, 9, 12, 11, 13],
        jobsTrend: const [5, 7, 6, 8, 9, 10],
        labels: const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'],
        jobsDone: 12,
        occupancy: 86,
        avgRating: 4.7,
        revenueThisPeriod: 13200000,
        revenueGrowthText: '+3,1%',
        jobsGrowthText: '+2,6%',
        occupancyGrowthText: '−1%',
        ratingGrowthText: '+1%',
        avgQueueBars: const [10, 13, 15, 12, 18, 21, 8],
        peakHourBars: const [20, 48, 61, 70, 65, 72, 40, 22],
        peakHourLabels: const [
          '08',
          '10',
          '12',
          '14',
          '16',
          '18',
          '20',
          '22'
        ],
        avgQueue: 14,
        peakRange: '12:00 - 18:00',
        efficiency: 90,
        forecastRevenue: [],
        topMechanics: [],
      );
    }

    return ReportData(
      serviceBreakdown: serviceBreakdown,
      revenueTrend: const [2.1, 3.4, 2.8, 3.0, 3.6, 3.1],
      jobsTrend: const [3, 5, 4, 6, 7, 6],
      labels: const ['08', '10', '12', '14', '16', '18'],
      jobsDone: 5,
      occupancy: 82,
      avgRating: 4.8,
      revenueThisPeriod: 3600000,
      revenueGrowthText: '+0,8%',
      jobsGrowthText: '+1%',
      occupancyGrowthText: '+0,5%',
      ratingGrowthText: '+0,2%',
      avgQueueBars: const [4, 6, 8, 12, 10, 6, 2],
      peakHourBars: const [6, 14, 22, 20, 18, 8, 4, 2],
      peakHourLabels: const [
        '08',
        '10',
        '12',
        '14',
        '16',
        '18',
        '20',
        '22'
      ],
      avgQueue: 12,
      peakRange: '12:00 - 16:00',
      efficiency: 91,
      forecastRevenue: [],
      topMechanics: [],
    );
  }
}
