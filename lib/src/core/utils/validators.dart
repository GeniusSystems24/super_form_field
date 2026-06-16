// ============================================================
// core/utils/validators.dart
// ------------------------------------------------------------
// The validation primitives shared by every Super…Field. A [Validator] is a
// pure `(value) -> error message | null` function; [runValidators] returns the
// FIRST failing message (or null when every validator passes). This is the
// exact contract the React `runValidators(value, validators)` helper used.
// ============================================================

/// A synchronous validator: returns an error message, or null when valid.
typedef Validator<T> = String? Function(T value);

/// Reports a field's current error (null == valid) to a host on every change.
typedef ValidityChanged = void Function(String? error);

/// Runs an ordered list of [validators] against [value] and returns the first
/// non-null error message, or null when all pass. Null entries are skipped.
String? runValidators<T>(T value, List<Validator<T>?>? validators) {
  if (validators == null) return null;
  for (final v in validators) {
    if (v == null) continue;
    final msg = v(value);
    if (msg != null && msg.isNotEmpty) return msg;
  }
  return null;
}
