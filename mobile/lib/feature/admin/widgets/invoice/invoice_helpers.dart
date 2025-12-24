class InvoiceHelpers {
  static String formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  static String formatDate(DateTime d) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Ags",
      "Sep",
      "Okt",
      "Nov",
      "Des"
    ];
    return "${d.day} ${months[d.month - 1]} ${d.year}";
  }

  static int calculateTotal(List<Map<String, dynamic>> serviceList) {
    return serviceList.fold(0, (sum, item) => sum + (item['harga'] as int));
  }
}
