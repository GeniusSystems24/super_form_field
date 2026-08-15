// ============================================================
// features/super_dropdown_button/presentation/controllers/
// super_dropdown_editing_controller.dart
// ------------------------------------------------------------
// Programmatic value controller for SuperDropdownButton and
// SuperDropdownButtonFormField.
// ============================================================

import 'package:flutter/widgets.dart';

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
  SuperDropdownEditingController({
    T? initialValue,
    bool isFixed = false,
    this.focusNode,
    this.formFieldKey,
    this.isHiden = false,
  }) : isFixed = ValueNotifier<bool>(isFixed),
       super(initialValue) {
    this.isFixed.addListener(_onFixedChanged);
  }

  /// Guards user and controller-driven mutations when set to `true`.
  final ValueNotifier<bool> isFixed;

  /// Optional focus node associated with this field.
  FocusNode? focusNode;

  /// Optional key for the inner [FormField], exposing its [FormFieldState].
  GlobalKey<FormFieldState<T>>? formFieldKey;

  /// Optional flag the UI can use to hide/show the field.
  ///
  /// The misspelling is retained for compatibility with the existing API.
  bool isHiden;

  /// Whether the controller currently has a non-null selection.
  bool get hasValue => value != null;

  @override
  set value(T? newValue) {
    if (isFixed.value) return;
    super.value = newValue;
  }

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

  void _onFixedChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    isFixed.removeListener(_onFixedChanged);
    isFixed.dispose();
    super.dispose();
  }
}
