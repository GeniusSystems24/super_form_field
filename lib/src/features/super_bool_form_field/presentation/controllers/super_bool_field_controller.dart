// ============================================================
// features/super_bool_form_field/presentation/controllers/super_bool_field_controller.dart
// ------------------------------------------------------------
// The MVC controller (the Model) for a boolean field — owns the on/off value
// and the touched state, holds the validator chain, and derives the error.
// Validation is silent until the field is toggled once (touched) or the host
// forces it. The controller never imports a widget.
// ============================================================

import 'package:flutter/widgets.dart';
import 'package:super_core/super_core.dart' show Validator;

import '../../../../core/utils/validators.dart';

class SuperBoolFieldController extends ChangeNotifier {
  SuperBoolFieldController({
    bool initialValue = false,
    bool isFixed = false,
    this.focusNode,
    this.formFieldKey,
    this.isHiden = false,
  }) : isFixed = ValueNotifier<bool>(isFixed),
       _value = initialValue {
    this.isFixed.addListener(_onFixedChanged);
  }

  /// Guards user and controller-driven mutations when set to `true`.
  final ValueNotifier<bool> isFixed;

  /// Optional focus node associated with this field.
  FocusNode? focusNode;

  /// Optional key reserved for the field's FormField integration.
  GlobalKey<FormFieldState<bool>>? formFieldKey;

  /// Optional flag the UI can use to hide/show the field.
  ///
  /// The misspelling is retained for compatibility with the existing API.
  bool isHiden;
  // ── value + interaction ──
  bool _value;
  bool _touched = false;

  // ── config (set by the View) ──
  List<Validator<bool>> _validators = const [];
  bool _forceError = false;
  FormValidityChanged? _onValidity;
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
    FormValidityChanged? onValidity,
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
    if (isFixed.value) return;
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
    if (isFixed.value) return;
    _value = v;
    _emit();
    notifyListeners();
  }

  void markTouched() {
    if (isFixed.value) return;
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
