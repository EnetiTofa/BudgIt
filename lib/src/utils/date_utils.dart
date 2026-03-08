// lib/src/utils/date_utils.dart

class AppDateUtils {
  /// Standardized multiplier for converting between weekly and monthly amounts.
  /// Using 52 / 12 is mathematically safer than a hardcoded 4.33 or 4.333
  /// and prevents the floating-point precision loss that causes $9.99 bugs.
  static const double weeksPerMonth = 52.0 / 12.0;

  /// Standardized multiplier for daily to monthly conversions.
  static const double daysPerMonth = 365.25 / 12.0;
}

/// Finds the first occurrence of a specific weekday in a given month.
/// [checkInWeekday] should be 1 (Monday) to 7 (Sunday).
DateTime getFirstCheckInDayOfMonth(int year, int month, int checkInWeekday) {
  // Start at the 1st of the target month
  final firstDayOfMonth = DateTime(year, month, 1);

  // Calculate how many days we need to add to reach the target weekday
  final offset = (checkInWeekday - firstDayOfMonth.weekday + 7) % 7;

  // Add the offset to get the exact date
  return firstDayOfMonth.add(Duration(days: offset));
}

/// Helper extension to strip the time off a DateTime for clean day-to-day comparisons
extension DateTimeComparison on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);
}
