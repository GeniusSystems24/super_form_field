import 'dart:math' as math;

import 'super_date_range.dart';

/// Computes a suggested range relative to [now].
typedef SuperDateRangeResolver = SuperDateRange Function(DateTime now);

/// Configurable preset shown beside the range calendars.
///
/// [resolve] is evaluated when the picker opens/applies the suggestion, so
/// relative presets stay current instead of baking dates at widget creation.
class SuperDateRangeSuggestion {
  const SuperDateRangeSuggestion({required this.label, required this.resolve});

  final String label;
  final SuperDateRangeResolver resolve;

  /// Package defaults. Pass `null` to `SuperRangeDateFormField.suggestions`
  /// to use these; pass an empty list to remove every default; or spread
  /// this list together with custom suggestions.
  static List<SuperDateRangeSuggestion> get defaults => const [
    SuperDateRangeSuggestion(label: 'Past 7 days', resolve: _past7Days),
    SuperDateRangeSuggestion(
      label: 'Previous 30 days',
      resolve: _previous30Days,
    ),
    SuperDateRangeSuggestion(
      label: 'Previous 6 months',
      resolve: _previous6Months,
    ),
    SuperDateRangeSuggestion(label: 'Previous year', resolve: _previousYear),
  ];

  static SuperDateRange _past7Days(DateTime now) {
    final end = _dateOnly(now);
    return SuperDateRange(
      start: end.subtract(const Duration(days: 6)),
      end: end,
    );
  }

  static SuperDateRange _previous30Days(DateTime now) {
    final end = _dateOnly(now);
    return SuperDateRange(
      start: end.subtract(const Duration(days: 29)),
      end: end,
    );
  }

  static SuperDateRange _previous6Months(DateTime now) {
    final end = _dateOnly(now);
    return SuperDateRange(start: _shiftMonths(end, -6), end: end);
  }

  static SuperDateRange _previousYear(DateTime now) {
    final end = _dateOnly(now);
    return SuperDateRange(start: _shiftYears(end, -1), end: end);
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime _shiftMonths(DateTime value, int delta) {
    final raw = value.year * 12 + value.month - 1 + delta;
    final year = raw ~/ 12;
    final month = raw % 12 + 1;
    final maxDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, math.min(value.day, maxDay));
  }

  static DateTime _shiftYears(DateTime value, int delta) {
    final year = value.year + delta;
    final maxDay = DateTime(year, value.month + 1, 0).day;
    return DateTime(year, value.month, math.min(value.day, maxDay));
  }
}
