// ============================================================
// features/super_choice_form_field/presentation/controllers/super_choice_field_controller.dart
// ------------------------------------------------------------
// The MVC controller (the Model) for the inline choice group. Owns the chosen
// value list and the touched state; derives the error from the validator chain.
// In single mode a pick replaces the selection; in [multiple] mode a pick
// toggles it (capped at maxSelections). Exposes a [single] convenience getter.
// The controller never imports a widget.
// ============================================================

import 'package:flutter/widgets.dart';

import '../../../../core/utils/validators.dart';

class SuperChoiceFieldController<T> extends ChangeNotifier {
  SuperChoiceFieldController({List<T>? initialValue})
    : _values = [...?initialValue];

  // ── value + interaction ──
  final List<T> _values;
  bool _touched = false;

  // ── config (set by the View) ──
  bool _multiple = false;
  int? _maxSelections;
  List<Validator<List<T>>> _validators = const [];
  bool _forceError = false;
  ValidityChanged? _onValidity;
  ValueChanged<List<T>>? _onChanged;
  String? _lastReported;

  // ── reads ──
  List<T> get values => List.unmodifiable(_values);
  bool get touched => _touched;
  int get count => _values.length;
  bool isSelected(T value) => _values.contains(value);

  /// Convenience for single-pick use — the one chosen value, or null.
  T? get single => _values.isEmpty ? null : _values.first;

  bool get atCapacity =>
      _maxSelections != null && _values.length >= _maxSelections!;

  String? get error => runValidators<List<T>>(values, _validators);
  String? get visibleError =>
      (_touched || _forceError) && error != null ? error : null;

  // ── View → controller config ──
  void configure({
    required bool multiple,
    int? maxSelections,
    required List<Validator<List<T>>> validators,
    required bool forceError,
    ValidityChanged? onValidity,
    ValueChanged<List<T>>? onChanged,
  }) {
    _multiple = multiple;
    _maxSelections = maxSelections;
    _validators = validators;
    _forceError = forceError;
    _onValidity = onValidity;
    _onChanged = onChanged;
  }

  void reportInitialValidity() => _reportValidity();

  /// Pick [value]. Single mode replaces the selection; multiple mode toggles it
  /// (blocked when adding past the cap).
  void pick(T value) {
    if (_multiple) {
      if (_values.contains(value)) {
        _values.remove(value);
      } else {
        if (atCapacity) return;
        _values.add(value);
      }
    } else {
      _values
        ..clear()
        ..add(value);
    }
    _touched = true;
    _emit();
    notifyListeners();
  }

  /// Replace the whole selection (external reset).
  void setValues(List<T> vs) {
    _values
      ..clear()
      ..addAll(vs);
    _emit();
    notifyListeners();
  }

  /// Set a single value (single-pick external reset).
  void setSingle(T? v) => setValues(v == null ? const [] : [v]);

  void clear() {
    if (_values.isEmpty) return;
    _values.clear();
    _touched = true;
    _emit();
    notifyListeners();
  }

  void markTouched() {
    if (_touched) return;
    _touched = true;
    notifyListeners();
  }

  void _emit() {
    _onChanged?.call(values);
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
