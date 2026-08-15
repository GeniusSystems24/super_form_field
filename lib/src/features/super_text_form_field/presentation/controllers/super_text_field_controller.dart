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
    bool isFixed = false,
    FocusNode? focusNode,
    this.formFieldKey,
    this.isHiden = false,
  }) : text = TextEditingController(text: initialValue),
       _obscured = obscured,
       isFixed = ValueNotifier<bool>(isFixed),
       focusNode = focusNode {
    _ownsFocusNode = this.focusNode == null;
    this.focusNode ??= FocusNode();
    text.addListener(_onTextChanged);
    this.focusNode?.addListener(_onFocusChanged);
    this.isFixed.addListener(_onFixedChanged);
  }

  /// Guards user and controller-driven mutations when set to `true`.
  final ValueNotifier<bool> isFixed;

  /// Optional focus node associated with this field.
  FocusNode? focusNode;

  /// Optional key for the inner [FormField], exposing its [FormFieldState].
  GlobalKey<FormFieldState<String>>? formFieldKey;

  /// Optional flag the UI can use to hide/show the field.
  ///
  /// The misspelling is retained for compatibility with the existing API.
  bool isHiden;

  late final bool _ownsFocusNode;

  /// The backing editing controller (value + selection).
  final TextEditingController text;

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
  bool get focused => focusNode?.hasFocus ?? false;
  bool get obscured => _obscured;

  /// The raw validation error (independent of touched state).
  String? get error => runValidators(value, _validators);

  /// The error to actually display — gated on touched / forceError.
  String? get visibleError =>
      (_touched || _forceError) && error != null ? error : null;

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
    if (isFixed.value) return;
    if (text.text == v) return;
    text.value = TextEditingValue(
      text: v,
      selection: TextSelection.collapsed(offset: v.length),
    );
  }

  /// Clear the field (the × affordance).
  void clear() => setValue('');

  /// Toggle password visibility.
  void toggleObscure() {
    if (isFixed.value) return;
    _obscured = !_obscured;
    notifyListeners();
  }

  /// Force the touched state (e.g. on a submit sweep).
  void markTouched() {
    if (isFixed.value) return;
    if (_touched) return;
    _touched = true;
    notifyListeners();
  }

  void _onTextChanged() {
    _reportValidity();
    notifyListeners();
  }

  void _onFocusChanged() {
    if (!(focusNode?.hasFocus ?? false)) _touched = true;
    notifyListeners();
  }

  void _onFixedChanged() {
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
    isFixed.removeListener(_onFixedChanged);
    isFixed.dispose();
    text.removeListener(_onTextChanged);
    focusNode?.removeListener(_onFocusChanged);
    text.dispose();
    if (_ownsFocusNode) focusNode?.dispose();
    super.dispose();
  }
}
