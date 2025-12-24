
String formatRupiah(num n) {
  final s = n.toInt().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final rev = s.length - i;
    b.write(s[i]);
    if (rev > 1 && rev % 3 == 1) b.write('.');
  }
  return 'Rp. $b';
}

String formatDate(DateTime? dt) {
  if (dt == null) return '-';
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
    'Des'
  ];
  return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
}

String formatEstWaktu(DateTime? dt) {
  if (dt == null) return '-';
  // kalau nanti mau hitung durasi dari scheduled_date ke estimated_time
  return '1 jam';
}

String formatTimeNow() {
  final now = DateTime.now();
  final hh = now.hour.toString().padLeft(2, '0');
  final mm = now.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

String formatTime(DateTime? dt) {
  if (dt == null) return '--:--';
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

String statusText(String s) {
  switch (s.toLowerCase()) {
    case 'completed':
      return '• Pekerjaan telah selesai';
    case 'in progress':
      return '• Pekerjaan sedang dikerjakan';
    case 'accept':
      return '• Pekerjaan dikonfirmasi';
    case 'cancelled':
      return '• Pekerjaan dibatalkan';
    default:
      return '• Menunggu konfirmasi';
  }
}

// ambil alamat secara aman kalau backend/model punya field itu
String customerAddressSafe(dynamic c) {
  try {
    if (c == null) return '-';
    final a = (c.address ??
            c['address'] ??
            c.alamat ??
            c['alamat'] ??
            c.addr ??
            c['addr'])
        ?.toString();
    if (a != null && a.trim().isNotEmpty) return a;
    return '-';
  } catch (_) {
    return '-';
  }
}

double calculateProgress(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return .25;
    case 'accept':
      return .5;
    case 'in progress':
      return .75;
    case 'completed':
      return 1.0;
    default:
      return .15;
  }
}
