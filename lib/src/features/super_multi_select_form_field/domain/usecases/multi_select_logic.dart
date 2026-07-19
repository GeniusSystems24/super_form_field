// ============================================================
// features/super_multi_select_form_field/domain/usecases/multi_select_logic.dart
// ------------------------------------------------------------
// Pure domain logic for the multi-select field: case-insensitive option
// filtering and the validator chain (required ▸ minSelections ▸ maxSelections ▸
// custom), operating on the selected `List<T>`. Generic over the value type. No
// Flutter imports — unit-testable in isolation.
// ============================================================

import 'package:super_form_field/super_form_field.dart' show SuperOption;
import '../../../../core/utils/validators.dart';

/// Multi-select business rules, grouped as a stateless helper.
abstract final class MultiSelectLogic {
  /// Filters [options] by a case-insensitive [query] over label + description.
  static List<SuperOption<T>> filter<T>(
    List<SuperOption<T>> options,
    String query,
  ) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return options;
    return options
        .where(
          (o) =>
              o.label.toLowerCase().contains(q) ||
              (o.description?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  /// Builds the validator chain for a multi-select field (required ▸ min ▸ max
  /// ▸ custom). Operates on the chosen value list.
  static List<Validator<List<T>>> buildValidators<T>({
    bool required = false,
    int? minSelections,
    int? maxSelections,
    List<Validator<List<T>>> extra = const [],
    String requiredMessage = 'Select at least one option',
  }) {
    return [
      if (required) (v) => v.isEmpty ? requiredMessage : null,
      if (minSelections != null)
        (v) => v.isNotEmpty && v.length < minSelections
            ? 'Select at least $minSelections options'
            : null,
      if (maxSelections != null)
        (v) => v.length > maxSelections
            ? 'Select at most $maxSelections options'
            : null,
      ...extra,
    ];
  }
}
