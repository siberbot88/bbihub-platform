
enum StaffRole {
  seniorMechanic,
  juniorMechanic,
  admin,
}

class StaffPerformance {
  final String name;
  final StaffRole role;
  final String avatarUrl;
  final int jobsDone;
  final int jobsInProgress;
  final int estimatedRevenue; // in rupiah

  const StaffPerformance({
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.jobsDone,
    required this.jobsInProgress,
    required this.estimatedRevenue,
  });

  factory StaffPerformance.fromJson(Map<String, dynamic> json) {
    // Parse role from string
    StaffRole parseRole(String roleStr) {
      switch (roleStr.toLowerCase()) {
        case 'mechanic':
        case 'seniormechanic': // Handles potential variations
          return StaffRole.seniorMechanic; // Defaulting to senior for now or add logic
        case 'juniormechanic':
          return StaffRole.juniorMechanic;
        case 'admin':
          return StaffRole.admin;
        default:
          return StaffRole.seniorMechanic;
      }
    }

    return StaffPerformance(
      name: json['name'] ?? 'Unknown',
      role: parseRole(json['role'] ?? 'mechanic'),
      avatarUrl: json['avatar_url'] ?? '',
      jobsDone: json['jobs_done'] ?? 0,
      jobsInProgress: json['jobs_in_progress'] ?? 0,
      estimatedRevenue: json['estimated_revenue'] ?? 0,
    );
  }

  // Helper for role display name
  String get roleDisplayName {
    switch (role) {
      case StaffRole.seniorMechanic:
        return 'Senior Mekanik';
      case StaffRole.juniorMechanic:
        return 'Junior Mekanik';
      case StaffRole.admin:
        return 'Admin';
    }
  }
}
