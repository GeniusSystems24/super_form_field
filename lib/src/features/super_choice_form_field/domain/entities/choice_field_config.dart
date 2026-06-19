// ============================================================
// features/super_choice_form_field/domain/entities/choice_field_config.dart
// ------------------------------------------------------------
// Pure value types for the inline choice group: how the options are laid out.
// ============================================================

/// How a [SuperChoiceFormField] lays out its options.
enum SuperChoiceStyle {
  /// A horizontal segmented control (best for 2–4 short, single-pick options).
  segmented,

  /// A vertical list of radio rows (single-pick from a longer list).
  radio,

  /// A vertical list of checkbox rows (multi-pick).
  checkbox,
}
