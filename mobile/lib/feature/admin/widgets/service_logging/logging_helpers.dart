class LoggingHelpers {
  static bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  static String formatDate(DateTime d) =>
      "${d.day} ${monthName(d.month)} ${d.year}";

  static String monthName(int m) => [
        "",
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
      ][m];

  static String weekdayShort(int wd) =>
      ["", "MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"][wd];
}
