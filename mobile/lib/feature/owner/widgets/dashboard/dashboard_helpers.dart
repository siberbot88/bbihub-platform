import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:flutter/material.dart';

enum SummaryRange { today, week, month }

/// Summary data for dashboard
class SummaryData {
  final num revenue;
  final int totalJob;
  final int totalDone;

  SummaryData({
    required this.revenue,
    required this.totalJob,
    required this.totalDone,
  });
}

/// Build summary based on date range
/// Build summary based on date range
SummaryData buildSummary(List<ServiceModel> list, SummaryRange range) {
  final now = DateTime.now();

  /// Check if service date is within the selected range
  bool inRange(ServiceModel s) {
    // Prioritize createdAt for accurate filtering of when the job was actually created/received
    final d = s.createdAt ?? s.scheduledDate ?? s.updatedAt;
    if (d == null) return false;

    switch (range) {
      case SummaryRange.today:
        // Hari ini: same year, month, and day
        return d.year == now.year &&
            d.month == now.month &&
            d.day == now.day;
            
      case SummaryRange.week:
        // Minggu ini: dari 7 hari yang lalu sampai sekarang
        final startOfWeek = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return d.isAfter(startOfWeek) && d.isBefore(endOfDay);
        
      case SummaryRange.month:
        // Bulan ini: same year and month
        return d.year == now.year && d.month == now.month;
    }
  }

  num revenue = 0;
  int totalJob = 0;
  int totalDone = 0;

  for (final s in list.where(inRange)) {
    final status = s.status.toLowerCase();

    // Pendapatan: dari service completed / paid / lunas
    if (['completed', 'paid', 'lunas', 'success'].contains(status)) {
      totalDone++;
      revenue += serviceRevenue(s);
    } 
    // Total Job: dari service pending, in progress, accept, atau menunggu pembayaran
    else if (['pending', 'in progress', 'accept', 'menunggu pembayaran', 'waiting_payment'].contains(status)) {
      totalJob++;
    }
  }

  return SummaryData(
    revenue: revenue,
    totalJob: totalJob,
    totalDone: totalDone,
  );
}

/// Calculate total revenue from a service (prioritize transaction/invoice)
num serviceRevenue(ServiceModel s) {
  // 1. Cek dari Transaction (amount)
  if (s.transaction != null) {
     final amt = s.transaction!['amount'];
     if (amt is num) return amt;
     if (amt is String) return num.tryParse(amt) ?? 0;
  }

  // 2. Cek dari Invoice (total)
  if (s.invoice != null) {
     final total = s.invoice!['total'];
     if (total is num) return total;
     if (total is String) return num.tryParse(total) ?? 0;
  }

  // 3. Fallback: Legacy (price + items)
  final partsTotal = (s.items ?? const [])
      .fold<num>(0, (a, it) => a + it.subtotal);
  return (s.price ?? 0) + partsTotal;
}

/// Format time as "X mins/hours/days ago"
String timeAgo(DateTime? dt) {
  if (dt == null) return '-';

  final now = DateTime.now();
  var diff = now.difference(dt);
  if (diff.isNegative) diff = Duration.zero;

  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
  if (diff.inDays == 1) return 'Kemarin';
  if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';

  final weeks = diff.inDays ~/ 7;
  if (weeks < 4) return '$weeks minggu yang lalu';

  final months = diff.inDays ~/ 30;
  if (months < 12) return '$months bulan yang lalu';

  final years = diff.inDays ~/ 365;
  return '$years tahun yang lalu';
}

/// Get Indonesian day name from weekday number
String dayNameId(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Senin';
    case DateTime.tuesday:
      return 'Selasa';
    case DateTime.wednesday:
      return 'Rabu';
    case DateTime.thursday:
      return 'Kamis';
    case DateTime.friday:
      return 'Jumat';
    case DateTime.saturday:
      return 'Sabtu';
    case DateTime.sunday:
      return 'Minggu';
    default:
      return '';
  }
}

/// Get Indonesian month abbreviation
String monthNameId(int month) {
  const bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return bulan[month - 1];
}

/// Format number as Indonesian Rupiah (with thousand separators)
String rupiah(num n) {
  final s = n.toInt().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final rev = s.length - i;
    b.write(s[i]);
    if (rev > 1 && rev % 3 == 1) b.write('.');
  }
  return b.toString();
}

/// Get Indonesian status label from English status
String statusLabel(String raw) {
  switch (raw.toLowerCase()) {
    case 'completed':
    case 'paid':
    case 'lunas':
    case 'success':
      return 'Selesai';
    case 'in progress':
    case 'accept':
      return 'Process';
    case 'menunggu pembayaran':
    case 'waiting_payment':
      return 'Menunggu Pembayaran';
    case 'cancelled':
      return 'Batal';
    default:
      return 'Pending';
  }
}

/// Get status color based on status string
Color statusColor(String raw) {
  switch (raw.toLowerCase()) {
    case 'completed':
    case 'paid':
    case 'lunas':
    case 'success':
      return Colors.green;
    case 'in progress':
    case 'accept':
      return Colors.blue;
    case 'menunggu pembayaran':
    case 'waiting_payment':
      return Colors.orangeAccent;
    case 'cancelled':
      return Colors.red;
    default:
      return Colors.orange;
  }
}

/// Extract workshop UUID from user object
String? pickWorkshopUuid(dynamic user) {
  if (user == null) return null;
  try {
    // ignore: avoid_dynamic_calls
    final ws = user.workshops;
    if (ws is List && ws.isNotEmpty) {
      final first = ws.first;
      if (first is Map) {
        return first['id']?.toString();
      }
      // ignore: avoid_dynamic_calls
      return first.id?.toString();
    }
  } catch (_) {}

  try {
    // ignore: avoid_dynamic_calls
    final emp = user.employment;
    if (emp != null) {
      dynamic w;
      if (emp is Map) {
        w = emp['workshop'];
      } else {
        // ignore: avoid_dynamic_calls
        w = emp.workshop;
      }

      if (w != null) {
        if (w is Map) {
          return w['id']?.toString();
        }
        // ignore: avoid_dynamic_calls
        return w.id?.toString();
      }
    }
  } catch (_) {}

  return null;
}
