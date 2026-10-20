class DayflowDates {
  const DayflowDates._();

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  static bool isToday(DateTime date, {DateTime? now}) {
    return isSameDay(date, now ?? DateTime.now());
  }

  static DateTime startOfWeek(DateTime date, {int weekStartsOn = 1}) {
    if (weekStartsOn < 1 || weekStartsOn > 7) {
      throw ArgumentError.value(
        weekStartsOn,
        'weekStartsOn',
        'Must be between 1 (Monday) and 7 (Sunday).',
      );
    }

    final normalized = dateOnly(date);
    final offset = (normalized.weekday - weekStartsOn + 7) % 7;
    return normalized.subtract(Duration(days: offset));
  }

  static DateTime addMonthsClamped(DateTime date, int months) {
    final firstOfTarget = DateTime(date.year, date.month + months, 1);
    final lastDay = DateTime(
      firstOfTarget.year,
      firstOfTarget.month + 1,
      0,
    ).day;

    return DateTime(
      firstOfTarget.year,
      firstOfTarget.month,
      date.day > lastDay ? lastDay : date.day,
    );
  }

  static bool isOverdue(DateTime? dueAt, {DateTime? now}) {
    if (dueAt == null) return false;
    return dueAt.isBefore(now ?? DateTime.now());
  }
}
