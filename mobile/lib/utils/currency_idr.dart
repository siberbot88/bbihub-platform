import 'package:intl/intl.dart';

class CurrencyIdr {
  static String format(num amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatNoSymbol(num amount) {
    final formatter = NumberFormat.decimalPattern('id_ID');
    return formatter.format(amount);
  }
}
