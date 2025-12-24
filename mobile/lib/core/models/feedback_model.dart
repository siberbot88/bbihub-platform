import 'package:flutter/material.dart';

class FeedbackResponse {
  final FeedbackSummary summary;
  final List<FeedbackItem> reviews;
  final PaginationMeta meta;

  FeedbackResponse({
    required this.summary,
    required this.reviews,
    required this.meta,
  });

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) {
    var data = json['data'];
    return FeedbackResponse(
      summary: FeedbackSummary.fromJson(data['summary']),
      reviews: (data['reviews']['data'] as List)
          .map((e) => FeedbackItem.fromJson(e))
          .toList(),
      meta: PaginationMeta.fromJson(data['reviews']),
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}

class FeedbackSummary {
  final double average;
  final int total;
  final Map<String, double> distribution; // Percentage (0.0 - 1.0)

  FeedbackSummary({
    required this.average,
    required this.total,
    required this.distribution,
  });

  factory FeedbackSummary.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> distRaw = json['distribution'] ?? {};
    final int total = json['total'] ?? 1; // avoid div by zero logic here if possible, but raw total is raw

    // Convert counts to progress percentages
    Map<String, double> dist = {};
    distRaw.forEach((key, value) {
      int count = value is int ? value : int.tryParse(value.toString()) ?? 0;
      dist[key] = total > 0 ? count / total : 0.0;
    });

    return FeedbackSummary(
      average: double.tryParse(json['average'].toString()) ?? 0.0,
      total: json['total'] ?? 0,
      distribution: dist,
    );
  }
}

class FeedbackItem {
  final String id;
  final String customerName;
  final String initials;
  final String timeAgo;
  final int rating;
  final String serviceName;
  final String comment;
  final Color avatarColor;

  FeedbackItem({
    required this.id,
    required this.customerName,
    required this.initials,
    required this.timeAgo,
    required this.rating,
    required this.serviceName,
    required this.comment,
    required this.avatarColor,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    final trx = json['transaction'] ?? {};
    final customer = trx['customer'] ?? {};
    final service = trx['service'] ?? {};
    final String name = customer['name'] ?? 'Pelanggan';
    
    // Initials logic
    String initials = "PL";
    if (name.isNotEmpty) {
      List<String> parts = name.trim().split(' ');
      if (parts.length > 1) {
        initials = parts[0][0] + parts[1][0];
      } else {
        initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1);
      }
    }

    // Avatar Color (Simple Hash)
    final colors = [
      Colors.blueAccent, Colors.purpleAccent, Colors.orangeAccent, 
      Colors.teal, Colors.redAccent, Colors.indigo, Colors.green
    ];
    final colorIndex = name.codeUnits.fold(0, (p, c) => p + c) % colors.length;

    // Time Ago (Simple calc or use backend if available, let's assume raw string for now or calc it)
    // Backend API didn't format time_ago, so we parse `submitted_at`
    String submittedAt = json['submitted_at'] ?? DateTime.now().toIso8601String();
    Duration diff = DateTime.now().difference(DateTime.parse(submittedAt));
    String ago = _formatDuration(diff);

    return FeedbackItem(
      id: json['id'],
      customerName: name,
      initials: initials.toUpperCase(),
      timeAgo: ago,
      rating: json['rating'] ?? 0,
      serviceName: service['name'] ?? 'Servis',
      comment: json['comment'] ?? '',
      avatarColor: colors[colorIndex],
    );
  }

  static String _formatDuration(Duration d) {
    if(d.inDays > 365) return "${(d.inDays / 365).floor()} tahun lalu";
    if(d.inDays > 30) return "${(d.inDays / 30).floor()} bulan lalu";
    if(d.inDays > 0) return "${d.inDays} hari lalu";
    if(d.inHours > 0) return "${d.inHours} jam lalu";
    if(d.inMinutes > 0) return "${d.inMinutes} menit lalu";
    return "Baru saja";
  }
}
