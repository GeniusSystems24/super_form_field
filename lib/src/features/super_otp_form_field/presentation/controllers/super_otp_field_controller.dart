// ============================================================
// features/super_otp_form_field/presentation/controllers/
// super_otp_field_controller.dart
// ------------------------------------------------------------
// State holder for SuperOTPFormField. It owns the single hidden editor that
// powers paste, SMS autofill, desktop keyboard input, and selection while the
// widget renders the code as separate visual cells.
// ============================================================

import 'package:flutter/widgets.dart';

import '../../../../core/utils/validators.dart';

/// Controller for `SuperOTPFormField`.
class SuperOTPFieldController extends ChangeNotifier {
  SuperOTPFieldController({String initialValue = ''})
    : text = TextEditingController(text: initialValue) {
    focusNode = FocusNode();
    text.addListener(_onTextChanged);
    focusNode.addListener(_onFocusChanged);
  }

  /// Backing editor used for keyboard input, paste, and autofill.
  final TextEditingController text;

  /// Focus node shared by the hidden editor and the visual OTP cells.
  late final FocusNode focusNode;

  bool _touched = false;
  List<Validator<String>> _validators = const [];
  bool _forceError = false;
  ValidityChanged? _onValidity;
  String? _lastReported;

  /// Current code.
  String get value => text.text;

  /// Whether the control has lost focus at least once or was marked manually.
  bool get touched => _touched;

  /// Whether the underlying editor is focused.
  bool get focused => focusNode.hasFocus;

  /// Current raw validation error.
  String? get error => runValidators(value, _validators);

  /// Error shown by the UI after touch or when forced by the host.
  String? get visibleError =>
      (_touched || _forceError) && error != null ? error : null;

  /// Updates validator and validity callback configuration from the widget.
  void configure({
    required List<Validator<String>> validators,
    required bool forceError,
    ValidityChanged? onValidity,
  }) {
    _validators = validators;
    _forceError = forceError;
    _onValidity = onValidity;
  }

  /// Reports initial validity after the first frame.
  void reportInitialValidity() => _reportValidity();

  /// Replaces the current code and moves the caret to its end.
  void setValue(String value) {
    if (text.text == value) return;
    text.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  /// Clears the current code.
  void clear() => setValue('');

  /// Requests focus and places the caret at the end of the code.
  void requestFocus() {
    focusNode.requestFocus();
    text.selection = TextSelection.collapsed(offset: text.text.length);
  }

  /// Marks the field as touched so validation becomes visible.
  void markTouched() {
    if (_touched) return;
    _touched = true;
    notifyListeners();
  }

  /// Clears the touched state, primarily for [FormState.reset].
  void resetTouched() {
    if (!_touched) return;
    _touched = false;
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
    final currentError = error;
    if (currentError == _lastReported) return;
    _lastReported = currentError;
    _onValidity?.call(currentError);
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
