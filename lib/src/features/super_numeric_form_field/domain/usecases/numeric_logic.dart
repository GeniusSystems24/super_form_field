// ============================================================
// features/super_numeric_form_field/domain/usecases/numeric_logic.dart
// ------------------------------------------------------------
// Pure domain logic for the numeric field: sanitising raw keystrokes, clamping
// + rounding on blur, and assembling the validator chain. Mirrors the React
// component's `parse`, `clampRound`, and `useMemo` validator build. No Flutter
// imports — unit-testable in isolation.
// ============================================================

import '../../../../core/utils/sff_format.dart';
import '../../../../core/utils/validators.dart';

/// Numeric field business rules, grouped as a stateless helper.
abstract final class NumericLogic {
  /// The effective lower bound: explicit [min], else 0 when negatives are
  /// disallowed, else null (unbounded below).
  static num? lowerBound({num? min, required bool allowNegative}) =>
      min ?? (allowNegative ? null : 0);

  /// Strips a raw editing string to a valid partial number: digits, an optional
  /// single leading `-` (only when [allowNegative]), and at most one `.`.
  static String sanitize(String raw, {required bool allowNegative}) {
    var s = raw.replaceAll(RegExp(r'[^0-9.\-]'), '');
    if (!allowNegative) {
      s = s.replaceAll('-', '');
    } else {
      // keep only a leading '-'
      final neg = s.startsWith('-');
      s = s.replaceAll('-', '');
      if (neg) s = '-$s';
    }
    final parts = s.split('.');
    if (parts.length > 2) s = '${parts[0]}.${parts.sublist(1).join()}';
    return s;
  }

  /// Parses a sanitised string to a number, or null when incomplete (`''`,
  /// `'-'`, `'.'`, `'-.'`).
  static num? parse(String sanitized) {
    if (sanitized.isEmpty || sanitized == '-' || sanitized == '.' || sanitized == '-.') {
      return null;
    }
    return double.tryParse(sanitized);
  }

  /// Clamps [n] into [min, max] and rounds to [decimals] fraction digits.
  static num clampRound(num n, {num? min, num? max, int decimals = 0}) {
    var v = n;
    if (min != null) v = v < min ? min : v;
    if (max != null) v = v > max ? max : v;
    final f = _pow10(decimals);
    return (v * f).round() / f;
  }

  static num _pow10(int n) {
    var r = 1;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }

  /// Builds the validator chain for a numeric field (required ▸ min ▸ max ▸
  /// custom). The first failing message wins.
  static List<Validator<num?>> buildValidators({
    bool required = false,
    num? min,
    num? max,
    int decimals = 0,
    bool grouping = true,
    bool allowNegative = true,
    List<Validator<num?>> extra = const [],
    String requiredMessage = 'This field is required',
  }) {
    final lo = lowerBound(min: min, allowNegative: allowNegative);
    return [
      if (required) (v) => v == null ? requiredMessage : null,
      if (lo != null)
        (v) => v != null && v < lo
            ? (lo == 0 ? 'Cannot be negative' : 'Must be at least ${SuperFormat.number(lo, decimals: decimals, grouping: grouping)}')
            : null,
      if (max != null)
        (v) => v != null && v > max
            ? 'Must be at most ${SuperFormat.number(max, decimals: decimals, grouping: grouping)}'
            : null,
      ...extra,
    ];
  }
}
