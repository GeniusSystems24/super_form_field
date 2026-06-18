// ============================================================
// features/super_date_form_field/domain/usecases/date_logic.dart
// ------------------------------------------------------------
// Pure domain logic for the date field: masking raw keystrokes into the
// `YYYY-MM-DD` shape, parsing a complete ISO string into a calendar-valid
// [DateTime], formatting a [DateTime] back to ISO, and assembling the validator
// chain (required ▸ min ▸ max ▸ custom). Mirrors the React DateColumn's
// `maskDate` + ISO regex + `validateCell` rules. No Flutter imports — fully
// unit-testable in isolation.
// ============================================================

import '../../../../core/utils/validators.dart';

/// Date-field business rules, grouped as a stateless helper.
abstract final class DateLogic {
  /// Matches a complete ISO calendar date: `2024-01-31`.
  static final RegExp isoRe = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  /// Strips a raw editing string down to the `YYYY-MM-DD` mask: digits only,
  /// capped at 8, with dashes inserted after the year and month.
  /// `mask('20240131') -> '2024-01-31'`, `mask('2024-1') -> '2024-1'`.
  static String mask(String raw) {
    final d = raw.replaceAll(RegExp(r'[^\d]'), '');
    final digits = d.length > 8 ? d.substring(0, 8) : d;
    var out = digits.length > 4 ? digits.substring(0, 4) : digits;
    if (digits.length > 4) {
      final mm = digits.length > 6 ? digits.substring(4, 6) : digits.substring(4);
      out += '-$mm';
    }
    if (digits.length > 6) {
      out += '-${digits.substring(6)}';
    }
    return out;
  }

  /// Parses a masked string into a calendar-valid date-only [DateTime], or
  /// `null` when the string is empty, incomplete, or not a real date
  /// (`2024-13-40` → null). The time component is always midnight.
  static DateTime? parse(String s) {
    final v = s.trim();
    if (!isoRe.hasMatch(v)) return null;
    final y = int.parse(v.substring(0, 4));
    final m = int.parse(v.substring(5, 7));
    final d = int.parse(v.substring(8, 10));
    if (m < 1 || m > 12 || d < 1 || d > 31) return null;
    final dt = DateTime(y, m, d);
    // Reject overflow (e.g. 2024-02-31 rolling into March).
    if (dt.year != y || dt.month != m || dt.day != d) return null;
    return dt;
  }

  /// Formats a [DateTime] to an ISO `YYYY-MM-DD` string. Returns `''` for null.
  static String format(DateTime? date) {
    if (date == null) return '';
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Strips the time component, returning a midnight-anchored date-only value.
  static DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  /// True when [a] and [b] fall on the same calendar day.
  static bool sameDay(DateTime? a, DateTime? b) =>
      a != null && b != null && a.year == b.year && a.month == b.month && a.day == b.day;

  /// Builds the validator chain for a date field (required ▸ min ▸ max ▸
  /// custom). The first failing message wins. Operates on the parsed
  /// `DateTime?`; the malformed-text error is raised separately by the
  /// controller.
  static List<Validator<DateTime?>> buildValidators({
    bool required = false,
    DateTime? minDate,
    DateTime? maxDate,
    List<Validator<DateTime?>> extra = const [],
    String requiredMessage = 'This field is required',
  }) {
    final lo = minDate == null ? null : dateOnly(minDate);
    final hi = maxDate == null ? null : dateOnly(maxDate);
    return [
      if (required) (v) => v == null ? requiredMessage : null,
      if (lo != null)
        (v) => v != null && v.isBefore(lo) ? 'Must be on or after ${format(lo)}' : null,
      if (hi != null)
        (v) => v != null && v.isAfter(hi) ? 'Must be on or before ${format(hi)}' : null,
      ...extra,
    ];
  }
}
