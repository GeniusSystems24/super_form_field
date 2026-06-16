// ============================================================
// core/utils/sff_format.dart
// ------------------------------------------------------------
// Intl-free number + byte formatters shared across the kit. GeniusLink keeps
// Western digits regardless of language and renders grouped thousands for
// numerics. Mirrors the React `glFmtNumber` / `glFmtBytes` helpers.
// ============================================================

/// Number + byte formatting helpers. No `intl` dependency.
abstract final class SuperFormat {
  /// Formats [n] with grouped thousands and [decimals] fraction digits:
  /// `number(1234.5, decimals: 2) -> "1,234.50"`. Returns '' for null/NaN.
  /// When [grouping] is false, only the fixed-decimal string is returned.
  static String number(num? n, {int decimals = 0, bool grouping = true}) {
    if (n == null || (n is double && n.isNaN)) return '';
    final fixed = n.toStringAsFixed(decimals);
    if (!grouping) return fixed;
    final neg = fixed.startsWith('-');
    final body = neg ? fixed.substring(1) : fixed;
    final parts = body.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    final frac = parts.length > 1 ? '.${parts[1]}' : '';
    return '${neg ? '-' : ''}${buf.toString()}$frac';
  }

  /// Human file size: `840 B`, `12 KB`, `3.4 MB`. Returns '' for null/NaN.
  static String bytes(num? b) {
    if (b == null || (b is double && b.isNaN)) return '';
    if (b < 1024) return '${b.toInt()} B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(0)} KB';
    return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
