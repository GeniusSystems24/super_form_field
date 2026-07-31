// ============================================================
// features/super_text_form_field/domain/entities/text_field_config.dart
// ------------------------------------------------------------
// Pure value types for the text field: the input kind it accepts. Density is
// shared (core `FieldDensity`).
// ============================================================

/// The kind of text a [SuperTextFormField] accepts.
enum SuperTextType {
  /// Free text (the default).
  text,

  /// Email — auto-validated against a basic `a@b.c` pattern.
  email,

  /// Phone number — uses the platform phone keyboard by default for
  /// single-line input.
  ///
  /// No locale-specific validation or formatting is imposed. Use `pattern`,
  /// `inputFormatters`, or custom validators when the accepted phone-number
  /// format must be restricted.
  phone,

  /// Password — characters obscured, with a reveal (eye) toggle.
  password,
}
