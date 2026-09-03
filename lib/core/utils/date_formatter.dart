import 'package:intl/intl.dart';

class DateFormatter {
  static String formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Kemarin';
    if (diff < 7) return DateFormat('EEEE', 'id_ID').format(date);
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }

  static String formatShort(DateTime date) {
    return DateFormat('d MMM', 'id_ID').format(date);
  }

  static String formatFull(DateTime date) {
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('d MMM yyyy HH:mm', 'id_ID').format(date);
  }
}
