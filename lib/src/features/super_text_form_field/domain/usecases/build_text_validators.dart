// ============================================================
// features/super_text_form_field/domain/usecases/build_text_validators.dart
// ------------------------------------------------------------
// Pure domain logic: assembles the ordered validator chain for a text field
// from its declarative constraints (required ▸ minLength ▸ maxLength ▸ email ▸
// pattern ▸ custom). Mirrors the React component's `useMemo` validator build.
// No Flutter imports — unit-testable in isolation.
// ============================================================

import '../../../../core/utils/validators.dart';
import '../entities/text_field_config.dart';

/// Basic email shape — `a@b.c` with no whitespace.
final RegExp kEmailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Builds the validator chain for a text field. The returned list is consumed
/// by [runValidators]; the first failing message wins.
List<Validator<String>> buildTextValidators({
  bool required = false,
  int? minLength,
  int? maxLength,
  SuperTextType type = SuperTextType.text,
  RegExp? pattern,
  String? patternMessage,
  List<Validator<String>> extra = const [],
  String requiredMessage = 'This field is required',
}) {
  return [
    if (required) (v) => v.trim().isEmpty ? requiredMessage : null,
    if (minLength != null)
      (v) => v.isNotEmpty && v.length < minLength
          ? 'Must be at least $minLength characters'
          : null,
    if (maxLength != null)
      (v) =>
          v.length > maxLength ? 'Must be at most $maxLength characters' : null,
    if (type == SuperTextType.email)
      (v) => v.isNotEmpty && !kEmailRe.hasMatch(v)
          ? 'Enter a valid email address'
          : null,
    if (pattern != null)
      (v) => v.isNotEmpty && !pattern.hasMatch(v)
          ? (patternMessage ?? 'Invalid format')
          : null,
    ...extra,
  ];
}
