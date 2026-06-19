// ============================================================
// features/super_numeric_form_field/presentation/controllers/super_numeric_field_controller.dart
// ------------------------------------------------------------
// The MVC controller (Model) for a numeric field. Holds the numeric value and
// interaction state, and owns the display transition that defines this field:
// grouped thousands while idle, clean raw digits while focused, clamp + round
// on blur. Exposes the +/- stepper AND keyboard stepping (↑/↓ by `step`,
// PageUp/PageDown by `largeStep`). The controller never imports a widget.
// ============================================================

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:super_core/super_core.dart' hide Validator, ValidityChanged;
import '../../../../core/utils/validators.dart';
import '../../domain/usecases/numeric_logic.dart';

class SuperNumericFieldController extends ChangeNotifier {
  SuperNumericFieldController({num? initialValue}) : _value = initialValue {
    text = TextEditingController(text: _formatted());
    focusNode = FocusNode(onKeyEvent: _onKey);
    text.addListener(_onTextChanged);
    focusNode.addListener(_onFocusChanged);
  }

  late final TextEditingController text;
  late final FocusNode focusNode;

  // ── value + interaction ──
  num? _value;
  bool _touched = false;
  bool _syncing = false; // guards programmatic text writes from re-entrancy

  // ── config (set by the View) ──
  num? _min;
  num? _max;
  int _decimals = 0;
  bool _grouping = true;
  bool _allowNegative = true;
  num _step = 1;
  num _largeStep = 10;
  bool _readOnly = false;
  bool _keyboardEnabled = true;

  // ── validation config ──
  List<Validator<num?>> _validators = const [];
  bool _forceError = false;
  ValidityChanged? _onValidity;
  ValueChanged<num?>? _onChanged;
  String? _lastReported;

  // ── reads ──
  num? get value => _value;
  bool get touched => _touched;
  bool get focused => focusNode.hasFocus;
  num? get lowerBound => NumericLogic.lowerBound(min: _min, allowNegative: _allowNegative);

  String? get error => runValidators(_value, _validators);
  String? get visibleError => (_touched || _forceError) && error != null ? error : null;

  String _formatted() => SuperFormat.number(_value, decimals: _decimals, grouping: _grouping);

  // ── View → controller config ──
  void configure({
    num? min,
    num? max,
    int decimals = 0,
    bool grouping = true,
    bool allowNegative = true,
    num step = 1,
    num? largeStep,
    bool readOnly = false,
    bool keyboardEnabled = true,
    required List<Validator<num?>> validators,
    required bool forceError,
    ValidityChanged? onValidity,
    ValueChanged<num?>? onChanged,
  }) {
    final fmtChanged = decimals != _decimals || grouping != _grouping;
    _min = min;
    _max = max;
    _decimals = decimals;
    _grouping = grouping;
    _allowNegative = allowNegative;
    _step = step;
    _largeStep = largeStep ?? step * 10;
    _readOnly = readOnly;
    _keyboardEnabled = keyboardEnabled;
    _validators = validators;
    _forceError = forceError;
    _onValidity = onValidity;
    _onChanged = onChanged;
    if (fmtChanged && !focused) {
      // Defer the re-format write to after the frame so we never mutate the
      // editing controller mid-build of a mounted field.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!focused) _writeText(_formatted());
      });
    }
  }

  /// Reports the current validity once — call after the first frame so a host
  /// `onValidity` that calls setState never runs during build.
  void reportInitialValidity() => _reportValidity();

  void _writeText(String s) {
    _syncing = true;
    text.value = TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));
    _syncing = false;
  }

  /// Programmatically set the value (external reset). Re-formats when idle.
  void setValue(num? v) {
    _value = v;
    if (!focused) _writeText(_formatted());
    _emit();
    notifyListeners();
  }

  /// Stepper: bump by ±[_step], clamped + rounded.
  void bump(int direction) => _applyDelta(direction * _step);

  /// Bump by ±[_largeStep] (PageUp / PageDown), clamped + rounded.
  void bumpLarge(int direction) => _applyDelta(direction * _largeStep);

  void _applyDelta(num delta) {
    final base = _value ?? 0;
    _value = NumericLogic.clampRound(
      base + delta,
      min: lowerBound,
      max: _max,
      decimals: _decimals,
    );
    _touched = true;
    if (focused) {
      _writeText(_value.toString());
    } else {
      _writeText(_formatted());
    }
    _emit();
    notifyListeners();
  }

  /// Handles ↑/↓ (step) and PageUp/PageDown (large step) while the field has
  /// focus. Wired to the focus node's `onKeyEvent`. Returns [KeyEventResult]
  /// so arrow keys are consumed here instead of doing nothing in a single-line
  /// field. No-op when read-only or keyboard stepping is disabled.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!_keyboardEnabled || _readOnly) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final k = event.logicalKey;
    if (k == LogicalKeyboardKey.arrowUp) {
      bump(1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowDown) {
      bump(-1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.pageUp) {
      bumpLarge(1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.pageDown) {
      bumpLarge(-1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onTextChanged() {
    if (_syncing) return;
    // Live editing: sanitise + parse.
    final sanitized = NumericLogic.sanitize(text.text, allowNegative: _allowNegative);
    if (sanitized != text.text) {
      _writeText(sanitized);
    }
    _value = NumericLogic.parse(sanitized);
    _emit();
    notifyListeners();
  }

  void _onFocusChanged() {
    if (focusNode.hasFocus) {
      // Enter edit mode → raw digits.
      _writeText(_value == null ? '' : _value.toString());
    } else {
      _touched = true;
      if (_value != null) {
        _value = NumericLogic.clampRound(_value!, min: lowerBound, max: _max, decimals: _decimals);
        _emit();
      }
      _writeText(_formatted());
    }
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

  @override
  void dispose() {
    text.removeListener(_onTextChanged);
    focusNode.removeListener(_onFocusChanged);
    text.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
