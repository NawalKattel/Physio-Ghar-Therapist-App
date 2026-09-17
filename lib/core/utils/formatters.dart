import 'package:intl/intl.dart';

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime startOfWeek(DateTime date) => DateTime(
  date.year,
  date.month,
  date.day - (date.weekday - DateTime.monday),
);

String formatWeekdayShort(DateTime date) => DateFormat('EEE').format(date);

String formatDateRange(DateTime start, DateTime end) => start.month == end.month
    ? '${start.day} – ${DateFormat('d MMM y').format(end)}'
    : '${DateFormat('d MMM').format(start)} – ${DateFormat('d MMM y').format(end)}';

String formatTime(DateTime time) => DateFormat('h:mm a').format(time);

String formatFullDate(DateTime date) =>
    DateFormat('EEEE, d MMM y').format(date);

String formatDate(DateTime date) => DateFormat('d MMM y').format(date);

String formatDateTime(DateTime date) =>
    DateFormat('d MMM y, h:mm a').format(date);

String formatShortDate(DateTime date) => DateFormat('EEE, d MMM').format(date);

String greetingFor(DateTime now) {
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 17) return 'Good afternoon';
  return 'Good evening';
}
