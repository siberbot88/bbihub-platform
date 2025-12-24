class Report {
  final String id;
  final String workshopUuid;
  final String reportType;
  final String reportData;
  final String? photo;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Report({
    required this.id,
    required this.workshopUuid,
    required this.reportType,
    required this.reportData,
    this.photo,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String? ?? '',
      workshopUuid: json['workshop_uuid'] as String? ?? '',
      reportType: json['report_type'] as String? ?? '',
      reportData: json['report_data'] as String? ?? '',
      photo: json['photo'] as String?,
      status: json['status'] as String? ?? 'baru',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workshop_uuid': workshopUuid,
      'report_type': reportType,
      'report_data': reportData,
      'photo': photo,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper to get status color
  String getStatusColor() {
    switch (status.toLowerCase()) {
      case 'baru':
        return '0xFF3B82F6'; // Blue
      case 'diproses':
        return '0xFFF59E0B'; // Yellow
      case 'selesai':
        return '0xFF10B981'; // Green  
      case 'ditolak':
        return '0xFFEF4444'; // Red
      default:
        return '0xFF6B7280'; // Gray
    }
  }

  // Helper to get status label
  String getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'baru':
        return 'Baru';
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }
}
