// ============================================================
// features/super_otp_form_field/domain/usecases/build_otp_validators.dart
// ------------------------------------------------------------
// Pure validator composition for one-time-password and verification-code
// fields. The widget supplies localized messages; this layer remains free of
// Flutter presentation dependencies.
// ============================================================

import 'package:super_core/super_core.dart' show Validator;


/// Builds the ordered validator chain used by the OTP form field.
///
/// Validation follows the package-wide first-error-wins rule:
///
/// 1. required value
/// 2. exact OTP length
/// 3. caller-provided validators
List<Validator<String>> buildOTPValidators({
  required bool required,
  required int length,
  required List<Validator<String>> extra,
  required String requiredMessage,
  required String lengthMessage,
}) {
  return <Validator<String>>[
    if (required) (value) => value.isEmpty ? requiredMessage : null,
    (value) {
      if (value.isEmpty && !required) return null;
      return value.length == length ? null : lengthMessage;
    },
    ...extra,
  ];
}
