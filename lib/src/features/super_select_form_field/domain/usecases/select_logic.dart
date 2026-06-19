// ============================================================
// features/super_select_form_field/domain/usecases/select_logic.dart
// ------------------------------------------------------------
// Pure domain logic for the single-select field: case-insensitive option
// filtering (label + description) and the validator chain (required ▸ custom).
// Generic over the value type. No Flutter imports — unit-testable in isolation.
// ============================================================

import '../../../../core/core.dart';

/// Single-select business rules, grouped as a stateless helper.
abstract final class SelectLogic {
  /// Filters [options] by a case-insensitive [query] over label + description.
  /// An empty/blank query returns the list unchanged.
  static List<SuperOption<T>> filter<T>(List<SuperOption<T>> options, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return options;
    return options
        .where((o) =>
            o.label.toLowerCase().contains(q) ||
            (o.description?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  /// Builds the validator chain for a single-select field (required ▸ custom).
  static List<Validator<T?>> buildValidators<T>({
    bool required = false,
    List<Validator<T?>> extra = const [],
    String requiredMessage = 'This field is required',
  }) {
    return [
      if (required) (v) => v == null ? requiredMessage : null,
      ...extra,
    ];
  }
}
