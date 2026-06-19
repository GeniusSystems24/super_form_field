// ============================================================
// features/super_choice_form_field/domain/usecases/choice_logic.dart
// ------------------------------------------------------------
// Pure domain logic for the inline choice group: the validator chain over the
// selected `List<T>` (required ▸ minSelections ▸ maxSelections ▸ custom).
// Generic over the value type. No Flutter imports — unit-testable in isolation.
// ============================================================

import '../../../../core/utils/validators.dart';

/// Choice-group business rules, grouped as a stateless helper.
abstract final class ChoiceLogic {
  /// Builds the validator chain for a choice field (required ▸ min ▸ max ▸
  /// custom). Operates on the chosen value list.
  static List<Validator<List<T>>> buildValidators<T>({
    bool required = false,
    int? minSelections,
    int? maxSelections,
    List<Validator<List<T>>> extra = const [],
    String requiredMessage = 'Select an option',
  }) {
    return [
      if (required) (v) => v.isEmpty ? requiredMessage : null,
      if (minSelections != null)
        (v) => v.isNotEmpty && v.length < minSelections
            ? 'Select at least $minSelections options'
            : null,
      if (maxSelections != null)
        (v) => v.length > maxSelections ? 'Select at most $maxSelections options' : null,
      ...extra,
    ];
  }
}
