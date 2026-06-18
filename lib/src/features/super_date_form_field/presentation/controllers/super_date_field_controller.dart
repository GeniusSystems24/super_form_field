// ============================================================
// features/super_date_form_field/presentation/controllers/super_date_field_controller.dart
// ------------------------------------------------------------
// The MVC controller (Model) for a date field. Holds the parsed `DateTime?`
// value and the masked editing buffer, masks keystrokes into `YYYY-MM-DD`
// live, and raises a "valid date" error when the text is non-empty but not a
// complete calendar date (mirrors the web DateColumn's validateCell). Exposes
// `setValue` / `pick` for the calendar popup, and arrow-key segment stepping
// (↑/↓ change the year, month, or day under the cursor). Never imports a widget.
// ============================================================

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/utils/validators.dart';
import '../../domain/usecases/date_logic.dart';

class SuperDateFieldController extends ChangeNotifier {
  SuperDateFieldController({DateTime? initialValue})
      : _value = initialValue == null ? null : DateLogic.dateOnly(initialValue) {
    text = TextEditingController(text: DateLogic.format(_value));
    focusNode = FocusNode(onKeyEvent: _onKey);
    text.addListener(_onTextChanged);
    focusNode.addListener(_onFocusChanged);
  }

  late final TextEditingController text;
  late final FocusNode focusNode;

  // ── value + interaction ──
  DateTime? _value;
  bool _touched = false;
  bool _syncing = false; // guards programmatic text writes from re-entrancy

  // ── validation config (set by the View) ──
  List<Validator<DateTime?>> _validators = const [];
  bool _forceError = false;
  String _malformedMessage = 'Enter a valid date (YYYY-MM-DD)';
  ValidityChanged? _onValidity;
  ValueChanged<DateTime?>? _onChanged;
  String? _lastReported;

  // ── stepping config (set by the View) ──
  DateTime? _minDate;
  DateTime? _maxDate;
  bool _keyboardEnabled = true;
  bool _readOnly = false;

  // ── reads ──
  DateTime? get value => _value;
  bool get touched => _touched;
  bool get focused => focusNode.hasFocus;

  /// True when the buffer holds non-empty text that is not a complete,
  /// calendar-valid date.
  bool get malformed => text.text.trim().isNotEmpty && _value == null;

  String? get error {
    if (malformed) return _malformedMessage;
    return runValidators(_value, _validators);
  }

  /// The error shown to the user — gated on first blur ([touched]) or
  /// [_forceError]. Errors surface via the suffix badge, never inline.
  String? get visibleError => (_touched || _forceError) && error != null ? error : null;

  // ── View → controller config ──
  void configure({
    required List<Validator<DateTime?>> validators,
    required bool forceError,
    String malformedMessage = 'Enter a valid date (YYYY-MM-DD)',
    DateTime? minDate,
    DateTime? maxDate,
    bool keyboardEnabled = true,
    bool readOnly = false,
    ValidityChanged? onValidity,
    ValueChanged<DateTime?>? onChanged,
  }) {
    _validators = validators;
    _forceError = forceError;
    _malformedMessage = malformedMessage;
    _minDate = minDate;
    _maxDate = maxDate;
    _keyboardEnabled = keyboardEnabled;
    _readOnly = readOnly;
    _onValidity = onValidity;
    _onChanged = onChanged;
  }

  /// Reports the current validity once — call after the first frame so a host
  /// `onValidity` that calls setState never runs during build.
  void reportInitialValidity() => _reportValidity();

  /// Marks the field touched without changing its value (submit-sweep helper).
  void markTouched() {
    if (_touched) return;
    _touched = true;
    notifyListeners();
  }

  void _writeText(String s) {
    _syncing = true;
    text.value = TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));
    _syncing = false;
  }

  /// Programmatically set the value (external reset / linked range). Re-formats
  /// the buffer to canonical ISO.
  void setValue(DateTime? v) {
    _value = v == null ? null : DateLogic.dateOnly(v);
    _writeText(DateLogic.format(_value));
    _emit();
    notifyListeners();
  }

  /// Pick a date from the calendar popup: commits the value, marks touched, and
  /// writes the canonical ISO text.
  void pick(DateTime date) {
    _value = DateLogic.dateOnly(date);
    _touched = true;
    _writeText(DateLogic.format(_value));
    _emit();
    notifyListeners();
  }

  /// Clear the field.
  void clear() {
    _value = null;
    _writeText('');
    _touched = true;
    _emit();
    notifyListeners();
  }

  // ── arrow-key segment stepping ───────────────────────────────────────────
  // The masked buffer is `YYYY-MM-DD`. The cursor's offset decides which segment
  // ↑/↓ steps: 0–4 → year, 5–7 → month, 8–10 → day. Day stepping rolls into the
  // next/previous month; month/year stepping clamps the day to the new month's
  // length. The result is clamped to [minDate, maxDate] when set.

  /// Segment index (0 year · 1 month · 2 day) for a cursor [offset].
  static int segmentForOffset(int offset) {
    if (offset <= 4) return 0;
    if (offset <= 7) return 1;
    return 2;
  }

  /// Step the segment under the cursor by [direction] (±1). Seeds today when the
  /// field is empty/malformed so an arrow press always lands on a valid date.
  void stepAtCursor(int direction) {
    final sel = text.selection;
    final offset = sel.baseOffset < 0 ? text.text.length : sel.baseOffset;
    stepSegment(segmentForOffset(offset), direction);
  }

  /// Step a specific [segment] (0 year · 1 month · 2 day) by [direction] (±1).
  void stepSegment(int segment, int direction) {
    if (_readOnly) return;
    final base = _value ?? DateLogic.dateOnly(DateTime.now());
    final DateTime next;
    switch (segment) {
      case 0:
        next = _addYears(base, direction);
      case 1:
        next = _addMonths(base, direction);
      default:
        next = DateTime(base.year, base.month, base.day + direction);
    }
    _value = _clampToBounds(DateLogic.dateOnly(next));
    _touched = true;
    _writeText(DateLogic.format(_value));
    _selectSegment(segment);
    _emit();
    notifyListeners();
  }

  DateTime _addYears(DateTime d, int delta) {
    final y = d.year + delta;
    final dim = DateTime(y, d.month + 1, 0).day; // last day of d.month in year y
    return DateTime(y, d.month, d.day > dim ? dim : d.day);
  }

  DateTime _addMonths(DateTime d, int delta) {
    final total = d.year * 12 + (d.month - 1) + delta;
    final y = total ~/ 12;
    final month = total % 12 + 1;
    final dim = DateTime(y, month + 1, 0).day;
    return DateTime(y, month, d.day > dim ? dim : d.day);
  }

  DateTime _clampToBounds(DateTime d) {
    final lo = _minDate == null ? null : DateLogic.dateOnly(_minDate!);
    final hi = _maxDate == null ? null : DateLogic.dateOnly(_maxDate!);
    if (lo != null && d.isBefore(lo)) return lo;
    if (hi != null && d.isAfter(hi)) return hi;
    return d;
  }

  /// Highlights the just-stepped [segment] so repeated arrow presses keep
  /// targeting it.
  void _selectSegment(int segment) {
    final ranges = [
      const [0, 4], // year
      const [5, 7], // month
      const [8, 10], // day
    ];
    final len = text.text.length;
    final start = ranges[segment][0].clamp(0, len);
    final end = ranges[segment][1].clamp(0, len);
    _syncing = true;
    text.selection = TextSelection(baseOffset: start, extentOffset: end);
    _syncing = false;
  }

  /// Wired to the focus node: ↑/↓ step the segment under the cursor. Left/right
  /// fall through so the cursor still moves between segments. No-op when
  /// disabled or read-only.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!_keyboardEnabled || _readOnly) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final k = event.logicalKey;
    if (k == LogicalKeyboardKey.arrowUp) {
      stepAtCursor(1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowDown) {
      stepAtCursor(-1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onTextChanged() {
    if (_syncing) return;
    final masked = DateLogic.mask(text.text);
    if (masked != text.text) _writeText(masked);
    _value = DateLogic.parse(masked);
    _emit();
    notifyListeners();
  }

  void _onFocusChanged() {
    if (!focusNode.hasFocus) {
      _touched = true;
      // Re-format a complete value to canonical ISO; leave malformed text as-is
      // so the user can see and fix it.
      if (_value != null) _writeText(DateLogic.format(_value));
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
