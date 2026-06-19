// ============================================================
// features/super_bool_form_field/domain/entities/bool_field_config.dart
// ------------------------------------------------------------
// Pure value types for the boolean field: how the on/off control is drawn.
// ============================================================

/// How a [SuperBoolFormField] renders its on/off control.
enum SuperBoolStyle {
  /// A sliding track + thumb (the default — best for settings / status flags).
  toggle,

  /// A checkbox square (best for "I accept …" acknowledgements).
  checkbox,
}
