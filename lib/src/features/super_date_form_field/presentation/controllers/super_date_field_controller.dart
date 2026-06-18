// ============================================================
// features/super_date_form_field/presentation/controllers/super_date_field_controller.dart
// ------------------------------------------------------------
// The MVC controller (Model) for a date field. The buffer is three segments —
// year · month · day — laid out as `YYYY-MM-DD`. Editing is SEGMENT-AWARE: the
// segment the cursor sits on is the one you edit. Typing overwrites that segment
// and auto-advances rightward (year → month → day) as each fills; the day is the
// last segment, so once it is complete extra digits keep re-editing the day.
// `↑`/`↓` step the active segment; `←`/`→` move between segments. A non-empty but
// incomplete buffer raises the "valid date" error on blur. Never imports a widget.
// ============================================================

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/utils/validators.dart';
import '../../domain/usecases/date_logic.dart';

class SuperDateFieldController extends ChangeNotifier {
  SuperDateFieldController({DateTime? initialValue})
      : _value = initialValue == null ? null : DateLogic.dateOnly(initialValue) {
    _partsFromValue();
    text = TextEditingController(text: DateLogic.format(_value));
    _lastComposed = text.text;
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

  // ── segmented editing state ──
  // _parts[0]=year (≤4 digits), [1]=month, [2]=day (≤2 digits each). Strings so
  // they can hold partial input mid-type. _seg is the active segment; _fresh is
  // true when the next digit should OVERWRITE the segment (just entered it).
  final List<String> _parts = ['', '', ''];
  int _seg = 0;
  bool _fresh = true;
  String _lastComposed = '';

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

  /// The active segment (0 year · 1 month · 2 day).
  int get activeSegment => _seg;

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

  /// Programmatically set the value (external reset / linked range). Re-formats
  /// the buffer to canonical ISO.
  void setValue(DateTime? v) {
    _value = v == null ? null : DateLogic.dateOnly(v);
    _partsFromValue();
    _seg = 0;
    _fresh = true;
    _render();
    _emit();
    notifyListeners();
  }

  /// Pick a date from the calendar popup: commits the value, marks touched, and
  /// writes the canonical ISO text.
  void pick(DateTime date) {
    _value = DateLogic.dateOnly(date);
    _partsFromValue();
    _seg = 0;
    _fresh = true;
    _touched = true;
    _render();
    _emit();
    notifyListeners();
  }

  /// Clear the field.
  void clear() {
    _value = null;
    _parts[0] = _parts[1] = _parts[2] = '';
    _seg = 0;
    _fresh = true;
    _touched = true;
    _render();
    _emit();
    notifyListeners();
  }

  // ── arrow-key segment stepping ───────────────────────────────────────────
  // Day stepping rolls into the next/previous month; month/year stepping clamps
  // the day to the new month's length. The result clamps to [minDate, maxDate].

  /// Segment index (0 year · 1 month · 2 day) for a cursor [offset] in a
  /// canonical `YYYY-MM-DD` buffer.
  static int segmentForOffset(int offset) {
    if (offset <= 4) return 0;
    if (offset <= 7) return 1;
    return 2;
  }

  /// Step the active segment by [direction] (±1). Seeds today when the field is
  /// empty/malformed so an arrow press always lands on a valid date.
  void stepAtCursor(int direction) => stepSegment(_seg, direction);

  /// Step a specific [segment] (0 year · 1 month · 2 day) by [direction] (±1).
  void stepSegment(int segment, int direction) {
    if (_readOnly) return;
    _seg = segment;
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
    _partsFromValue();
    _fresh = true;
    _touched = true;
    _render();
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

  // ── segmented typing ──────────────────────────────────────────────────────

  int _cap(int seg) => seg == 0 ? 4 : 2;

  void _partsFromValue() {
    if (_value == null) {
      _parts[0] = _parts[1] = _parts[2] = '';
    } else {
      _parts[0] = _value!.year.toString().padLeft(4, '0');
      _parts[1] = _value!.month.toString().padLeft(2, '0');
      _parts[2] = _value!.day.toString().padLeft(2, '0');
    }
  }

  /// Append/overwrite a digit into the active segment, auto-advancing as it
  /// fills. Empty trailing segments stay empty until typed — the value is not
  /// considered complete until every segment is full-width.
  void _typeDigit(String d) {
    if (_readOnly) return;
    final cap = _cap(_seg);
    if (_fresh) {
      _parts[_seg] = d;
      _fresh = false;
    } else if (_parts[_seg].length < cap) {
      _parts[_seg] = _parts[_seg] + d;
    } else {
      _parts[_seg] = d; // segment already full (day) → start over
    }
    _afterDigit();
    _commit();
  }

  // Decides whether the active segment is complete (and clamps it), then either
  // advances to the next segment or — for the day — re-arms `_fresh` so the next
  // digit overwrites the day again.
  void _afterDigit() {
    final p = _parts[_seg];
    if (p.isEmpty) return;
    final n = int.tryParse(p) ?? 0;
    if (_seg == 0) {
      if (p.length >= 4) _advance();
    } else if (_seg == 1) {
      if (p.length >= 2) {
        _parts[1] = n.clamp(1, 12).toString().padLeft(2, '0');
        _advance();
      } else if (n > 1) {
        // 2–9 can only be a single-digit month → complete it.
        _parts[1] = p.padLeft(2, '0');
        _advance();
      }
    } else {
      if (p.length >= 2) {
        _parts[2] = n.clamp(1, 31).toString().padLeft(2, '0');
        _fresh = true; // stay on day; next digit overwrites
      } else if (n > 3) {
        _parts[2] = p.padLeft(2, '0');
        _fresh = true;
      }
    }
  }

  void _advance() {
    _parts[_seg] = _parts[_seg].padLeft(_cap(_seg), '0');
    if (_seg < 2) {
      _seg++;
      _fresh = true;
    }
  }

  void _backspace() {
    if (_readOnly) return;
    final p = _parts[_seg];
    if (p.isNotEmpty) {
      _parts[_seg] = p.substring(0, p.length - 1);
      _fresh = false;
    } else if (_seg > 0) {
      _seg--;
      _fresh = false;
    }
    _commit();
  }

  /// A separator key (`-` `/` `.` `:` space) commits the active segment and
  /// jumps to the next one.
  void _jumpSeparator() {
    if (_readOnly) return;
    if (_parts[_seg].isNotEmpty) _parts[_seg] = _parts[_seg].padLeft(_cap(_seg), '0');
    if (_seg < 2) {
      _seg++;
      _fresh = true;
    }
    _commit();
  }

  void _moveSeg(int delta) {
    final n = _seg + delta;
    if (n < 0 || n > 2) return;
    if (_parts[_seg].isNotEmpty) _parts[_seg] = _parts[_seg].padLeft(_cap(_seg), '0');
    _seg = n;
    _fresh = true;
    _commit();
  }

  // Recompute the value from the parts and re-render.
  void _commit() {
    _recomputeValue();
    _render();
    _emit();
    notifyListeners();
  }

  void _recomputeValue() {
    if (_full(0) && _full(1) && _full(2)) {
      final iso = '${_parts[0]}-${_parts[1]}-${_parts[2]}';
      _value = DateLogic.parse(iso);
    } else {
      _value = null;
    }
  }

  /// A segment is full when it holds its capacity of digits (4 year · 2 month ·
  /// 2 day) — the gate for forming a complete [DateTime].
  bool _full(int i) => _parts[i].length == _cap(i);

  // Compose the display text from the parts (completed segments padded, the
  // active segment shown raw) and select the active segment.
  void _render() {
    var maxShown = _seg;
    for (var i = 0; i < 3; i++) {
      if (_parts[i].isNotEmpty && i > maxShown) maxShown = i;
    }
    final buf = StringBuffer();
    var selStart = 0;
    var selEnd = 0;
    for (var i = 0; i <= maxShown; i++) {
      if (i > 0) buf.write('-');
      final start = buf.length;
      final seg = i == _seg ? _parts[i] : (_parts[i].isEmpty ? '' : _parts[i].padLeft(_cap(i), '0'));
      buf.write(seg);
      if (i == _seg) {
        selStart = start;
        selEnd = buf.length;
      }
    }
    final t = buf.toString();
    _lastComposed = t;
    _syncing = true;
    text.value = TextEditingValue(
      text: t,
      selection: TextSelection(baseOffset: selStart, extentOffset: selEnd),
    );
    _syncing = false;
  }

  /// The active segment for a cursor [offset] in the CURRENT (possibly partial)
  /// buffer, located by its dash positions.
  int _segFromOffset(int offset) {
    final t = text.text;
    final firstDash = t.indexOf('-');
    if (firstDash < 0) return 0;
    final secondDash = t.indexOf('-', firstDash + 1);
    if (offset <= firstDash) return 0;
    if (secondDash < 0 || offset <= secondDash) return 1;
    return 2;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (_readOnly) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final hw = HardwareKeyboard.instance;
    // Let OS / app shortcuts (copy, paste, select-all, …) through.
    if (hw.isControlPressed || hw.isMetaPressed || hw.isAltPressed) return KeyEventResult.ignored;
    final k = event.logicalKey;

    // Arrow stepping (gated on keyboardShortcuts); shift+arrow falls through.
    if (k == LogicalKeyboardKey.arrowUp && _keyboardEnabled && !hw.isShiftPressed) {
      stepAtCursor(1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowDown && _keyboardEnabled && !hw.isShiftPressed) {
      stepAtCursor(-1);
      return KeyEventResult.handled;
    }
    // Segment navigation.
    if (k == LogicalKeyboardKey.arrowLeft && !hw.isShiftPressed) {
      _moveSeg(-1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowRight && !hw.isShiftPressed) {
      _moveSeg(1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.backspace) {
      _backspace();
      return KeyEventResult.handled;
    }
    final ch = event.character;
    if (ch != null && ch.length == 1) {
      if (RegExp(r'[0-9]').hasMatch(ch)) {
        _typeDigit(ch);
        return KeyEventResult.handled;
      }
      if ('-/.: '.contains(ch)) {
        _jumpSeparator();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  // Fires for paste / IME text changes AND selection-only changes (clicks).
  void _onTextChanged() {
    if (_syncing) return;
    if (text.text == _lastComposed) {
      // Selection-only change (mouse click) → re-target the active segment.
      final off = text.selection.baseOffset;
      if (off >= 0) {
        _seg = _segFromOffset(off);
        _fresh = true;
      }
      return;
    }
    // Paste / IME fallback: mask left-to-right and resync the segments.
    final masked = DateLogic.mask(text.text);
    final segs = masked.split('-');
    _parts[0] = segs.isNotEmpty ? segs[0] : '';
    _parts[1] = segs.length > 1 ? segs[1] : '';
    _parts[2] = segs.length > 2 ? segs[2] : '';
    _seg = _parts[2].isNotEmpty ? 2 : (_parts[1].isNotEmpty ? 1 : 0);
    _fresh = true;
    _recomputeValue();
    _render();
    _emit();
    notifyListeners();
  }

  void _onFocusChanged() {
    if (focusNode.hasFocus) {
      // Entering the field: sync segments from the value and arm the year for
      // overwrite (a mouse click then re-targets the clicked segment).
      _partsFromValue();
      _seg = 0;
      _fresh = true;
      _render();
    } else {
      _touched = true;
      // Complete a single-digit month/day (3 → 03) so a nearly-finished entry
      // resolves; leave a partial year as-is (it stays an error to fix).
      for (final i in const [1, 2]) {
        if (_parts[i].length == 1) _parts[i] = _parts[i].padLeft(2, '0');
      }
      _recomputeValue();
      // Re-format a complete value to canonical ISO; leave a malformed buffer
      // as-is so the user can see and fix it.
      if (_value != null) _partsFromValue();
      _render();
      _emit();
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
