// ============================================================
// features/super_bool_form_field/domain/usecases/build_bool_validators.dart
// ------------------------------------------------------------
// Pure domain logic: assembles the validator chain for a boolean field. The one
// built-in rule is `mustBeTrue` (the "you must accept / enable this" gate used
// by terms acknowledgements and required compliance flags). No Flutter imports.
// ============================================================

import '../../../../core/utils/validators.dart';

/// Builds the validator chain for a boolean field (mustBeTrue ▸ custom).
List<Validator<bool>> buildBoolValidators({
  bool mustBeTrue = false,
  List<Validator<bool>> extra = const [],
  String mustBeTrueMessage = 'This must be enabled to continue',
}) {
  return [if (mustBeTrue) (v) => v ? null : mustBeTrueMessage, ...extra];
}
