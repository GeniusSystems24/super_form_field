// ============================================================
// features/super_bool_form_field/presentation/controllers/super_bool_field_controller.dart
// ------------------------------------------------------------
// The MVC controller (the Model) for a boolean field — owns the on/off value
// and the touched state, holds the validator chain, and derives the error.
// Validation is silent until the field is toggled once (touched) or the host
// forces it. The controller never imports a widget.
// ============================================================

import 'package:flutter/widgets.dart';

import '../../../../core/utils/validators.dart';

class SuperBoolFieldController extends ChangeNotifier {
  SuperBoolFieldController({bool initialValue = false}) : _value = initialValue;

  // ── value + interaction ──
  bool _value;
  bool _touched = false;

  // ── config (set by the View) ──
  List<Validator<bool>> _validators = const [];
  bool _forceError = false;
  ValidityChanged? _onValidity;
  ValueChanged<bool>? _onChanged;
  String? _lastReported;

  // ── reads ──
  bool get value => _value;
  bool get touched => _touched;

  String? get error => runValidators<bool>(_value, _validators);
  String? get visibleError =>
      (_touched || _forceError) && error != null ? error : null;

  // ── View → controller config ──
  void configure({
    required List<Validator<bool>> validators,
    required bool forceError,
    ValidityChanged? onValidity,
    ValueChanged<bool>? onChanged,
  }) {
    _validators = validators;
    _forceError = forceError;
    _onValidity = onValidity;
    _onChanged = onChanged;
  }

  void reportInitialValidity() => _reportValidity();

  /// Set the value (marks touched). Used by user interaction.
  void set(bool v) {
    if (_value == v) return;
    _value = v;
    _touched = true;
    _emit();
    notifyListeners();
  }

  /// Flip the value.
  void toggle() => set(!_value);

  /// Programmatically set the value WITHOUT marking touched (external reset).
  void setValue(bool v) {
    _value = v;
    _emit();
    notifyListeners();
  }

  void markTouched() {
    if (_touched) return;
    _touched = true;
    notifyListeners();
  }

  void _emit() {
    _onChanged?.call(_value);
    _reportValidity();
  }

  void _reportValidity() {
    final e = error;
    if (e != _lastReported) {
      _lastReported = e;
      _onValidity?.call(e);
    }
  }
}
