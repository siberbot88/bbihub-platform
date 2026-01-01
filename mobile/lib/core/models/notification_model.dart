class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String timeAgo; // Helper for UI

  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.timeAgo,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['created_at']).toLocal();
    final data = json['data'] != null ? Map<String, dynamic>.from(json['data']) : <String, dynamic>{};
    
    return NotificationModel(
      id: json['id'],
      title: json['title'] ?? data['title'] ?? 'Notifikasi',
      message: json['message'] ?? data['message'] ?? data['body'] ?? 'Pesan baru',
      type: json['type'],
      isRead: json['read_at'] != null, // Laravel uses read_at, not is_read usually, but let's support both if needed
      createdAt: date,
      timeAgo: _timeAgo(date),
      data: data,
    );
  }

  static String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays} hari lalu';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}
