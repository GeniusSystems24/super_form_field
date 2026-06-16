// ============================================================
// features/super_text_form_field/presentation/controllers/super_text_field_controller.dart
// ------------------------------------------------------------
// The MVC controller (the Model) for a text field — the single source of truth
// the thin View renders and forwards events to. It owns the text value and the
// interaction state (focused / touched / obscured), holds the resolved
// validator chain, and derives the error. Validation is silent until the field
// has been touched (first blur) or the host forces it. The controller never
// imports a widget.
// ============================================================

import 'package:flutter/widgets.dart';

import '../../../../core/utils/validators.dart';

class SuperTextFieldController extends ChangeNotifier {
  SuperTextFieldController({
    String initialValue = '',
    bool obscured = false,
  })  : text = TextEditingController(text: initialValue),
        _obscured = obscured {
    focusNode = FocusNode();
    text.addListener(_onTextChanged);
    focusNode.addListener(_onFocusChanged);
  }

  /// The backing editing controller (value + selection).
  final TextEditingController text;

  /// The field's focus node (focus + blur drive `touched`).
  late final FocusNode focusNode;

  // ── interaction state ──
  bool _touched = false;
  bool _obscured;

  // ── validation config (set by the View) ──
  List<Validator<String>> _validators = const [];
  bool _forceError = false;
  ValidityChanged? _onValidity;
  String? _lastReported;

  // ── reads ──
  String get value => text.text;
  bool get touched => _touched;
  bool get focused => focusNode.hasFocus;
  bool get obscured => _obscured;

  /// The raw validation error (independent of touched state).
  String? get error => runValidators(value, _validators);

  /// The error to actually display — gated on touched / forceError.
  String? get visibleError => (_touched || _forceError) && error != null ? error : null;

  // ── View → controller config ──
  /// Re-points the validator chain / force flag / validity callback. Called by
  /// the View on build + prop changes. Reports validity if it changed.
  void configure({
    required List<Validator<String>> validators,
    required bool forceError,
    ValidityChanged? onValidity,
  }) {
    _validators = validators;
    _forceError = forceError;
    _onValidity = onValidity;
  }

  /// Reports the current validity once — call after the first frame so a host
  /// `onValidity` that calls setState never runs during build.
  void reportInitialValidity() => _reportValidity();

  /// Programmatically set the text (e.g. external reset).
  void setValue(String v) {
    if (text.text == v) return;
    text.value = TextEditingValue(text: v, selection: TextSelection.collapsed(offset: v.length));
  }

  /// Clear the field (the × affordance).
  void clear() => setValue('');

  /// Toggle password visibility.
  void toggleObscure() {
    _obscured = !_obscured;
    notifyListeners();
  }

  /// Force the touched state (e.g. on a submit sweep).
  void markTouched() {
    if (_touched) return;
    _touched = true;
    notifyListeners();
  }

  void _onTextChanged() {
    _reportValidity();
    notifyListeners();
  }

  void _onFocusChanged() {
    if (!focusNode.hasFocus) _touched = true;
    notifyListeners();
  }

  void _reportValidity() {
    final e = error;
    if (e != _lastReported) {
      _lastReported = e;
      _onValidity?.call(e);
    }
  }

  @override
  void dispose() {
    text.removeListener(_onTextChanged);
    focusNode.removeListener(_onFocusChanged);
    text.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
