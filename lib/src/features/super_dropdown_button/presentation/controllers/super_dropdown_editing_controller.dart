// ============================================================
// features/super_dropdown_button/presentation/controllers/
// super_dropdown_editing_controller.dart
// ------------------------------------------------------------
// Programmatic value controller for SuperDropdownButton and
// SuperDropdownButtonFormField.
// ============================================================

import 'package:flutter/foundation.dart';

/// Controls the selected value of a Super dropdown.
///
/// Use [value] to read or assign the current selection. Assigning a different
/// value notifies every attached dropdown so its visible selection updates.
///
/// The controller stores the typed domain value rather than a
/// `SuperOption<T>`. This keeps it independent from a particular option list.
///
/// Remember to call [dispose] when a controller is owned by a [State] object.
class SuperDropdownEditingController<T> extends ValueNotifier<T?> {
  /// Creates a controller with an optional [initialValue].
  SuperDropdownEditingController({T? initialValue}) : super(initialValue);

  /// Whether the controller currently has a non-null selection.
  bool get hasValue => value != null;

  /// Sets the selected value programmatically.
  ///
  /// This is equivalent to assigning [value] directly.
  void setValue(T? newValue) {
    value = newValue;
  }

  /// Clears the current selection.
  void clear() {
    value = null;
  }
}
