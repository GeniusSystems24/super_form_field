import '../../../../core/utils/validators.dart';
import '../entities/super_date_range.dart';

/// Pure date-range rules shared by controller, validation and picker UI.
abstract final class RangeDateLogic {
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool sameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isWithinBounds(
    DateTime date, {
    DateTime? minDate,
    DateTime? maxDate,
  }) {
    final value = dateOnly(date);
    final min = minDate == null ? null : dateOnly(minDate);
    final max = maxDate == null ? null : dateOnly(maxDate);
    if (min != null && value.isBefore(min)) return false;
    if (max != null && value.isAfter(max)) return false;
    return true;
  }

  static DateTime clamp(DateTime date, {DateTime? minDate, DateTime? maxDate}) {
    final value = dateOnly(date);
    final min = minDate == null ? null : dateOnly(minDate);
    final max = maxDate == null ? null : dateOnly(maxDate);
    if (min != null && value.isBefore(min)) return min;
    if (max != null && value.isAfter(max)) return max;
    return value;
  }

  /// Applies preset boundaries while preserving fixed values and enforcing
  /// min/max constraints. Returns null when a fixed boundary is missing or
  /// when the resulting range cannot be made valid.
  static SuperDateRange? constrainSuggestion({
    required SuperDateRange suggestion,
    required DateTime? currentStart,
    required DateTime? currentEnd,
    required bool isStartFixed,
    required bool isEndFixed,
    DateTime? minDate,
    DateTime? maxDate,
  }) {
    final start = isStartFixed
        ? currentStart == null
              ? null
              : dateOnly(currentStart)
        : clamp(suggestion.start, minDate: minDate, maxDate: maxDate);
    final end = isEndFixed
        ? currentEnd == null
              ? null
              : dateOnly(currentEnd)
        : clamp(suggestion.end, minDate: minDate, maxDate: maxDate);

    if (start == null || end == null) return null;
    if (!isWithinBounds(start, minDate: minDate, maxDate: maxDate) ||
        !isWithinBounds(end, minDate: minDate, maxDate: maxDate)) {
      return null;
    }
    if (start.isAfter(end)) return null;
    return SuperDateRange(start: start, end: end);
  }

  static List<Validator<SuperDateRange?>> buildValidators({
    required bool required,
    DateTime? minDate,
    DateTime? maxDate,
    List<Validator<SuperDateRange?>> extra = const [],
    String requiredMessage = 'This field is required',
    String orderMessage = 'Start date must not be after end date',
    String Function(String value)? minDateMessage,
    String Function(String value)? maxDateMessage,
  }) {
    final lo = minDate == null ? null : dateOnly(minDate);
    final hi = maxDate == null ? null : dateOnly(maxDate);
    return [
      if (required) (value) => value == null ? requiredMessage : null,
      (value) {
        if (value == null) return null;
        return dateOnly(value.start).isAfter(dateOnly(value.end))
            ? orderMessage
            : null;
      },
      if (lo != null)
        (value) {
          if (value == null) return null;
          return dateOnly(value.start).isBefore(lo)
              ? (minDateMessage?.call(formatDate(lo)) ??
                    'Must start on or after ${formatDate(lo)}')
              : null;
        },
      if (hi != null)
        (value) {
          if (value == null) return null;
          return dateOnly(value.end).isAfter(hi)
              ? (maxDateMessage?.call(formatDate(hi)) ??
                    'Must end on or before ${formatDate(hi)}')
              : null;
        },
      ...extra,
    ];
  }

  static String formatDate(DateTime? value) {
    if (value == null) return '';
    final date = dateOnly(value);
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String formatRange(
    DateTime? start,
    DateTime? end, {
    String separator = ' → ',
  }) {
    final left = formatDate(start);
    final right = formatDate(end);
    if (left.isEmpty && right.isEmpty) return '';
    return '$left$separator$right';
  }
}
